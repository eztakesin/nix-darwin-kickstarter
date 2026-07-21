# 用 sops + YubiKey (age) 加密助记词,存入 Apple Keychain

## 架构总览

```
助记词(明文,只存在于你脑子/纸上/输入瞬间)
   │  sops 加密(age,两个 recipient,any-of 任一可解)
   ▼
密文 mnemonic.yaml ──┬─→ Apple Keychain(generic password 条目)
                     └─→ ~/secrets/ 文件副本(密文可多处备份,越多越好)

钥匙 A(日常):YubiKey PIV 槽里的 age 身份 —— 插卡 + PIN + 触摸
钥匙 B(灾难):软件 age 密钥 —— 私钥只抄在纸上,离线保存
```

要点:**密文的安全完全靠钥匙**,所以密文可以放心多处冗余;
两把钥匙 any-of(任一把都能独立解密),灾难恢复靠纸钥,日常靠卡。
千万不要配置成"两把都要"(sops 多 key_groups 门限)——那是反向单点故障。

> 郑重声明:管真金白银的种子词,正道是硬件钱包 + 金属/纸质离线备份。
> 本方案适合做"第 N 份冗余",不要当唯一副本。

---

## 第 0 步:工具

sops、age、ykman 已在系统里;缺 `age-plugin-yubikey`,临时进 shell:

```fish
nix shell nixpkgs#age-plugin-yubikey
sops --version   # 需要 ≥ 3.9(--filename-override 和 age 插件支持)
```

想常驻就把 `age-plugin-yubikey` 加进 home 配置(cliPackages)。
注意:**sops 运行时 PATH 上必须能找到 age-plugin-yubikey**,否则解密时报
`could not find plugin`。

## 第 1 步:YubiKey PIV 健康检查(吸取 OpenPGP 锁卡教训)

PIV 和 OpenPGP 是同一根卡上**完全独立**的两个应用,PIN 各是各的:

```fish
ykman piv info
```

看三样东西:

- `PIN tries remaining`(默认 PIN `123456`)
- `PUK tries remaining`(默认 PUK `12345678`;PUK 用来解锁 PIN)
- 如果 PIN/PUK 还是默认值,先改掉,并**把 PUK 抄在纸上**:

```fish
ykman piv access change-pin
ykman piv access change-puk
```

PIN 锁了用 PUK 解(`ykman piv access unblock-pin`);PUK 也锁了只能
`ykman piv reset`(清空 PIV,age 身份就没了——所以才需要纸钥兜底)。

## 第 2 步:在卡上生成 age 身份

```fish
age-plugin-yubikey    # 交互式:选空槽 → 起名(如 mnemonic)→ 选策略
```

策略建议(高价值秘密):

| 选项 | 建议 | 含义 |
| --- | --- | --- |
| PIN policy | `once` | 每次插卡会话输一次 PIN(`always` = 每次解密都输,更严也更烦) |
| Touch policy | `always` | 每次解密必须物理触摸——防远程静默解密,**推荐** |

完成后拿两样东西:

```fish
age-plugin-yubikey --list       # recipient:age1yubikey1…(公开,用于加密)
mkdir -p ~/.config/sops/age
age-plugin-yubikey --identity >> ~/.config/sops/age/keys.txt   # 身份存根(非私钥,可进 dotfiles)
set -Ux SOPS_AGE_KEY_FILE ~/.config/sops/age/keys.txt          # 让 sops 找得到
```

## 第 3 步:生成纸面备份钥

```fish
age-keygen
```

输出两行关键内容:`# public key: age1…`(记下,加密用)和
`AGE-SECRET-KEY-1…`(**只抄到纸上**,建议两份异地;抄完逐字符校对)。

然后清理痕迹:`clear`,并清终端回滚缓冲(kitty:`cmd+k`)。
私钥不进任何文件、不进剪贴板、不发给任何人(包括我)。

## 第 4 步:建目录和 `.sops.yaml`

```fish
mkdir -p ~/secrets && cd ~/secrets
```

`~/secrets/.sops.yaml`(参考 oxa 的锚点风格,单机简化版):

```yaml
keys:
  # 日常:YubiKey PIV age 身份(插卡 + PIN + touch)
  - &macbook-yk age1yubikey1把你的填这里
  # 灾难恢复:纸面备份钥(私钥只存在纸上)
  - &paper age1把你的填这里

creation_rules:
  - path_regex: .*\.yaml$
    key_groups:
      - age:
          - *macbook-yk
          - *paper
```

## 第 5 步:加密助记词

`read -s` 隐藏输入 → 不经过 shell 历史、不经过编辑器(nvim 的
swap/undo 文件会泄漏明文,所以不用编辑器路线):

```fish
cd ~/secrets
read -s -P 'mnemonic> ' m
echo "mnemonic: $m" | sops -e --filename-override mnemonic.yaml /dev/stdin > mnemonic.yaml
set -e m
```

`--filename-override` 让 stdin 也能命中 `.sops.yaml` 的 path_regex。

## 第 6 步:三重验证(没验证过的备份等于不存在)

```fish
# ① 卡解密(应弹 PIN,并要求触摸;能看到明文即通过)
sops -d --extract '["mnemonic"]' mnemonic.yaml

# ② 灾难演练:拔掉 YubiKey,用纸上抄的私钥解
read -s -P 'paper secret> ' pk        # 照纸逐字输入 AGE-SECRET-KEY-1…
SOPS_AGE_KEY=$pk sops -d mnemonic.yaml >/dev/null; and echo PAPER-KEY-OK
set -e pk
```

②必须做——它同时验证了"纸抄对了"和"纸钥真的在 recipient 列表里"。
两项都过,才继续。

## 第 7 步:密文进 Keychain

fish 的命令替换按行分割,多行密文必须 `string collect`:

```fish
security add-generic-password -s mnemonic-sops -a (whoami) \
    -w (cat mnemonic.yaml | string collect)

# 注意:security -w 对多行内容会输出 hex 编码,读取必须先 xxd -r -p 解码。
# 读回并解密验证 keychain 里的副本完好:
security find-generic-password -s mnemonic-sops -w | xxd -r -p | \
    sops -d --input-type yaml --output-type yaml /dev/stdin >/dev/null; and echo KEYCHAIN-OK
```

首次读取弹 Keychain 授权时选**"允许"而不是"始终允许"**,保留每次弹窗这道闸。
`security` 写的是本地 login keychain,不走 iCloud 同步。
`~/secrets/mnemonic.yaml` 文件副本建议保留(密文冗余无害,可再备份到私有仓库)。

## 第 8 步:日常取用(可包成 fish function)

```fish
function mnemonic-show -d "decrypt mnemonic from keychain via YubiKey"
    security find-generic-password -s mnemonic-sops -w | xxd -r -p | \
        sops -d --input-type yaml --output-type yaml --extract '["mnemonic"]' /dev/stdin
end
```

(已由 home/fish.nix 声明式管理,rebuild 后直接可用。)

想复制到剪贴板:`mnemonic-show | pbcopy`,用完 `echo -n | pbcopy` 清掉。

## 多个秘密:通用快捷函数(home/fish.nix 声明式管理)

```fish
secret-save monero    # 隐藏输入 → sops 加密 → ~/secrets/monero.yaml + Keychain 条目 monero-sops
secret-show monero    # Keychain → hex 解码 → sops 解密(插卡 + PIN + 触摸)→ 只输出该字段
```

任意名字都行(mnemonic 那份对应 `secret-show mnemonic`;`mnemonic-show` 是它的别名)。
Monero 注意:16 词 Polyseed 是现行默认(词内嵌钱包生日),25 词是 legacy;
legacy 种子最好把 restore height 一并记下(可另存 `secret-save monero-height`)。

## 运维备忘

- **改了 `.sops.yaml`(加/换 recipient)后**,对每个已有文件跑
  `sops updatekeys <file>`,否则新规则只影响新文件(oxa 那份密文里
  漂着一个规则外的旧 recipient,就是没跑 updatekeys 的痕迹)。
  updatekeys 之后记得刷新 Keychain 里的副本(第 7 步重做)。
- **加第二把 YubiKey**:新卡生成身份 → recipient 加进 `.sops.yaml` →
  `sops updatekeys` → 新卡的 identity 也 append 进 keys.txt。
- **轮换数据钥**:`sops -r -i mnemonic.yaml`。
- 别忘了:age 纸钥和 PIV PUK 是你的两条命,分开放,定期确认还在。
