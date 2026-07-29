# Firefox 加固(arkenfox)—— nix 声明式管理

## 架构

```
dotfiles/firefox/user-overrides.js   我的覆盖(版本控制)
        +
arkenfox user.js（fetchurl 钉版本 + hash）
        ↓  home/firefox.nix 里 concatTextFile 合并
   ~/.config/firefox/user.js         nix 管理,每次 rebuild 更新
        ↑  一次性建立的符号链接
<profile>/user.js                    Firefox 启动时读取
```

替代了 arkenfox 官方的 `updater.sh` + `prefsCleaner.sh` 流程:合并在**构建时**完成,
不再需要手动跑脚本。

## 为什么要那条桥接符号链接

macOS TCC 保护 `~/Library/Application Support/Firefox`,home-manager 直接往里写会得到
`Operation not permitted`。而为此给终端「完全磁盘访问权限」代价太大——那等于让终端里
跑的**任何**命令都能读取所有受保护数据(其他浏览器 profile、邮件、信息、备份)。

所以让 nix 只写不受保护的 `~/.config/firefox/user.js`,profile 里放一个指向它的链接。
**日常 rebuild 完全不需要任何特殊权限。**

## 一次性设置

只有建立那条链接需要一次 FDA。建议用**系统自带的 Terminal.app**(而不是日常用的
kitty)来做,用完立刻撤销,这样你的日常终端始终没有这个权限:

1. 系统设置 → 隐私与安全性 → 完全磁盘访问权限 → 加入 **Terminal**,打开开关
2. 完全退出并重开 Terminal.app,执行(先确保 Firefox 已退出):

   ```sh
   P="$HOME/Library/Application Support/Firefox/Profiles/0ba1cm4u.default-nightly"

   # arkenfox + 我的覆盖
   ln -s ~/.config/firefox/user.js "$P/user.js"

   # 界面自定义(隐藏标签栏等)
   mkdir -p "$P/chrome"
   ln -s ~/.config/firefox/userChrome.css "$P/chrome/userChrome.css"
   ```

   若已存在手写的旧文件,`ln` 会失败——先 `rm` 掉再链接。

3. 回到系统设置,**把 Terminal 的开关关掉**(链接已建好,以后不再需要)

> profile 目录名来自 `about:profiles` 的 "Root Directory";换 profile 时同时更新
> 这里和 `home/firefox.nix` 里的 `profileDir`。

## 日常流程

改 `dotfiles/firefox/user-overrides.js` → `darwin-rebuild switch` → 重启 Firefox。

验证:`about:config` 搜 `_my_overrides.parrot`,应显示
`END: user-overrides.js loaded`(出现 END 说明整个覆盖区都执行完了,中途没有语法错误)。

## 升级 arkenfox

上游发布新版后,改 `home/firefox.nix` 里的 tag,取新 hash:

```fish
nix store prefetch-file https://raw.githubusercontent.com/arkenfox/user.js/<tag>/user.js
```

升级前扫一眼 [release notes](https://github.com/arkenfox/user.js/releases),
它会列出该版本改动/移除了哪些 pref。

## 两个已知边界

- **删除 pref 不会自动回滚**:`user.js` 只强制它包含的项。从覆盖里**删掉**某条后,
  它的最后取值仍留在 `prefs.js` 里。需要重置时,关掉 Firefox 跑一次 arkenfox 的
  `prefsCleaner.sh`,或用 Firefox 的「刷新」。新增/修改不受影响。
- **主题不归 nix 管**:`extensions.activeThemeID` 固定了**选择**,但 XPI 本体要从
  [AMO](https://addons.mozilla.org/) 装一次(丢进 profile 的 `extensions/` 会被
  `extensions.autoDisableScopes`(默认 15)禁用,而调低它等于削弱 arkenfox 的
  防旁加载防线)。换机器/重建 profile 时需要重装一次主题。

## 当前覆盖的影响(务必知情)

`user-overrides.js` 关闭了 **WebRTC** 和 **WebGL**、启用了 **RFP**(抗指纹):

- 浏览器内的视频通话(Meet/Teams 网页版)不可用
- 部分 3D、地图、canvas 重度站点会出问题
- 时区/分辨率被指纹化处理,某些站点会认为你在别的地区

遇到"这个网站怎么坏了",先回来查这三条。
