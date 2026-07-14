# Zellij 入门手册

> 对应配置:`macbook/home/zellij.nix`(zellij 0.44.x,键位全部为默认值,
> 摘自源码 `assets/config/default.kdl`,不是凭印象写的)。

## 0. 你的环境已经配好了什么

- **自动启动**:每开一个新终端(kitty 窗口/标签)都会自动进入 zellij
- **主题**:catppuccin-latte(内置主题,和 btop/kitty 一致)
- **鼠标可用**:滚轮翻回滚,**选中即复制**到 macOS 剪贴板(pbcopy)
- **回滚缓冲**:100 000 行
- 启动小贴士弹窗已关闭

## 1. 心智模型(先建立这个,键位都是顺出来的)

```
Session(会话,可脱离/重连)
└── Tab(标签页,底栏左侧)
    └── Pane(面板,分屏单元)
```

zellij 是**模态**的,像 vim:平时在 Normal 模式,按 `Ctrl 字母` 进入某个
功能模式(Pane 模式/Tab 模式/…),再按单键执行动作,动作完通常自动回
Normal。**底部状态栏永远显示当前模式下所有可用按键**——这是活的速查表,
前两周不用背任何键位,看底栏就行。

## 2. 三十秒生存指南

| 需求 | 按键 |
|---|---|
| 程序的 Ctrl-p/Ctrl-s 被 zellij 抢了 | `Ctrl g` 锁定(再按解锁)——**用 nvim/fzf 前先锁** |
| 我要出去(保留现场) | `Ctrl o` `d` 脱离(detach),之后 `zellij attach` 回来 |
| 彻底退出 zellij | `Ctrl q` |
| 迷路了 | 看底栏;或按 `Esc`/对应 `Ctrl 键` 回 Normal |

## 3. 免前缀高频键(Alt 系,任何模式直接按)

| 按键 | 动作 |
|---|---|
| `Alt n` | 新面板(自动排布) |
| `Alt h/j/k/l` 或 `Alt 方向键` | 在面板间移动焦点(h/l 到边缘会切标签页) |
| `Alt +` / `Alt -` | 放大/缩小当前面板 |
| `Alt f` | 浮动面板开关(临时开个悬浮终端跑命令,再按收起) |
| `Alt [` / `Alt ]` | 切换预设排布(横排/竖排/网格轮换) |
| `Alt i` / `Alt o` | 当前标签页左移/右移 |

日常 80% 的操作就是 `Alt n` + `Alt hjkl` + `Alt f`。

## 4. 各模式速查(`Ctrl 键` 进入,同键或 `Esc` 退出)

### Pane 面板模式 —— `Ctrl p`
| 键 | 动作 |
|---|---|
| `r` / `d` | 向右 / 向下分屏 |
| `n` | 新面板(自动位置) |
| `s` | 堆叠式新面板(stacked,同位置摞起来) |
| `x` | 关闭当前面板 |
| `f` | 全屏切换(≈ tmux zoom) |
| `w` | 浮动面板开关;`e` 浮动↔嵌入互转 |
| `c` | 重命名面板 |
| `h/j/k/l` | 移动焦点;`p` 轮换焦点 |
| `z` | 面板边框开关;`i` 钉住浮动面板 |

### Tab 标签页模式 —— `Ctrl t`
| 键 | 动作 |
|---|---|
| `n` / `x` | 新建 / 关闭标签页 |
| `r` | 重命名 |
| `1`–`9` | 跳转到第 N 个 |
| `h`/`l`(或方向键) | 上一个/下一个 |
| `Tab` | 在最近两个标签页间来回 |
| `b` | 把当前面板拆出去成新标签页;`[` `]` 拆到左/右侧 |
| `s` | **同步输入**开关(一次输入广播到本页所有面板,批量操作服务器用) |

### Resize 调整大小 —— `Ctrl n`
`h/j/k/l` 向该方向增大,`H/J/K/L` 缩小,`+`/`-` 整体增减。

### Move 挪动面板 —— `Ctrl h`
`h/j/k/l` 把面板本体往那个方向搬;`n`/`Tab` 顺移。

### Scroll 回滚/搜索 —— `Ctrl s`
| 键 | 动作 |
|---|---|
| `j/k`、`Ctrl f`/`Ctrl b`、`d`/`u` | 行 / 整页 / 半页滚动 |
| `s` | 进入搜索:输入词 `Enter`,然后 `n`/`p` 下一个/上一个,`c` 大小写,`o` 整词,`w` 回绕 |
| `e` | **用 nvim 打开整个回滚缓冲**(杀手锏:在编辑器里搜索/复制/保存输出) |
| `Ctrl c` | 跳回底部并退出 |

### Session 会话模式 —— `Ctrl o`
| 键 | 动作 |
|---|---|
| `d` | 脱离(detach)——会话继续活着 |
| `w` | **会话管理器**(浮窗列出所有会话,回车切换,还能恢复已退出的会话) |
| `c` | 配置面板;`p` 插件管理;`l` 布局管理;`a` 关于 |

## 5. tmux 老手通道 —— `Ctrl b`

zellij 内置 tmux 兼容模式,`Ctrl b` 后按 tmux 肌肉记忆:

`"` 下分屏 · `%` 右分屏 · `c` 新标签 · `,` 重命名 · `p`/`n` 前后标签 ·
`z` 全屏 · `[` 进回滚 · 方向键/`h j k l` 移动焦点 · 再按 `Ctrl b` = 发送
字面 Ctrl-b。

对照你熟悉的 tmux 配置:`bind v/s` 分屏 → `Ctrl p` `r`/`d`;`C-hjkl` 切
面板 → `Alt hjkl`(连前缀都不用);`HJKL` 调大小 → `Ctrl n` 后 `hjkl`。

## 6. 复制粘贴(macOS)

- **选中即复制**:鼠标拖选/双击选词,松手就进系统剪贴板(配置里接了 pbcopy)
- 粘贴用 kitty 的 `Cmd V`(zellij 不管粘贴)
- 想要 kitty 原生选择(绕过 zellij 鼠标接管):按住 `Shift`/`Fn` 再拖
- 大段复制的正确姿势:`Ctrl s` `e` 用 nvim 开回滚,想怎么摘就怎么摘

## 7. 会话:脱离、重连、恢复

```fish
zellij ls                 # 列出会话(含 EXITED —— 可复活)
zellij attach 名字        # 重连;attach -c 名字 = 没有就建
zellij -s 工作            # 指定名字新建
zellij delete-session 名字 --force   # 删掉(含已退出的)
zellij kill-all-sessions  # 全杀
```

- 会话名是随机词组(如 `cubic-piano`),`Ctrl o` `w` 里可视化切换更方便
- zellij 默认**序列化会话**:机器重启后 `zellij ls` 里旧会话显示 EXITED,
  `attach` 即恢复布局(运行中的进程当然回不来,但面板结构在)

## 8. 自动启动的开关

fish 集成生成的启动片段遵循几个环境变量,想调整行为不用改 nix:

| 变量 | 效果 |
|---|---|
| `ZELLIJ` 已设置 | 跳过自动启动(所以 zellij 内开 shell 不会套娃);想开一个"裸"终端:`env ZELLIJ=0 fish` |
| `ZELLIJ_AUTO_ATTACH=true` | 自动 attach 到既有会话而不是每次新建 |
| `ZELLIJ_AUTO_EXIT=true` | 退出 zellij 时连终端一起关 |

想永久关掉自动启动:`home/zellij.nix` 里把 `enableFishIntegration` 改
`false`,之后手动 `zellij` 启动。

## 9. 建议的头两天练习路径

1. 开终端(自动进入)→ `Alt n` 开两个面板 → `Alt hjkl` 来回跳
2. `Ctrl p` `f` 全屏一个面板再退出;`Alt f` 玩浮动面板
3. `Ctrl t` `n` 开新标签,`r` 改名,`Tab` 来回切
4. 跑个长输出命令,`Ctrl s` 滚上去,`s` 搜个词,再 `e` 用 nvim 打开
5. `Ctrl o` `d` 脱离,`zellij attach` 回来——理解"会话不死"
6. 在 nvim 里发现按键被抢 → `Ctrl g` 锁定,养成习惯
