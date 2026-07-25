# qalc & numbat:命令行里的单位换算 / 汇率 / 计算器

三件套的分工:

| 工具 | 形态 | 拿手好戏 |
| --- | --- | --- |
| `qalc`(包名 libqalculate) | CLI 一次性 + REPL | 汇率、单位、日常"什么都能算" |
| `numbat` | REPL 为主 | 物理量纲检查、科学计算、可编程 |
| Qalculate.app(qalculate-qt) | GUI | qalc 同引擎的图形界面 |

---

## 先说 REPL 是什么

REPL = **R**ead–**E**val–**P**rint **L**oop(读取–求值–打印–循环):
运行程序后进入一个**交互式对话界面**,你输入一行,它立刻算出一行,
然后等你输入下一行——就像 python 不带参数运行后的 `>>>` 界面,
或者你熟悉的 `fish` 本身(shell 就是命令的 REPL)。

对计算器来说,REPL 的好处是**上下文保留**:上一步结果可以直接引用
(qalc 里用 `ans`,numbat 里用 `ans` 或变量),适合连续推演;
而"一次性模式"(命令行参数直接给表达式)适合在脚本或临时算一下。

---

## qalc:日常主力

### 一次性模式(shell 里直接用)

```fish
qalc "30 mph to km/h"          # 48.28032 km/h
qalc "100 USD to CNY"          # 100 USD ≈ CNY 678.87
qalc "5 feet 3 inch to cm"     # 160.02 cm
qalc "20% of 340"              # 68
qalc "2 h 15 min to min"       # 135 min
qalc -t "sqrt(2)"              # -t = terse,只输出结果(适合脚本/管道)
```

注意表达式要加引号(`%`、`(` 等对 fish 有特殊含义)。

### REPL 模式

直接运行 `qalc` 进入交互界面:

```
> 100 EUR to CNY
> ans * 12          # ans = 上一个结果
> x = 1.08          # 定义变量
> 5000 CNY / x to EUR
> help              # 内置帮助
> exit
```

### 汇率

- 第一次用货币单位、或汇率过期(默认 7 天)时,qalc 会**提示是否更新**,
  回车确认即可;数据源是 ECB 等公开源,缓存在本地,之后离线可用。
- 主动更新:REPL 里输入 `exrates`,或 shell 里 `qalc -e "1 USD to CNY"`
  (`-e/--exrates` = 启动时先更新汇率)。
- 支持的不只是法币:`100 USD to BTC` 也能算。

### 其他常用姿势

```
> 0xff to bin            # 进制转换 → 0b11111111
> 1500 kcal to kJ        # 能量
> 30 C to F              # 温度(摄氏→华氏)
> factor(3600)           # 质因数分解
> set precision 10       # 提高显示精度(REPL 内设置)
```

---

## numbat:带量纲检查的科学计算 REPL

numbat 的核心卖点:**每个数都带物理量纲**,单位错误在算之前就被抓住:

```
>>> 1 m + 1 s
error: left hand side: Length / right hand side: Time   ← 直接拒绝
```

### 基本使用

运行 `numbat` 进 REPL(`>>>` 提示符),转换用 `->`(或 `to`):

```
>>> 30 mph -> km/h            # 48.2803 km/h
>>> 100 USD -> CNY            # 677 CNY(ECB 汇率,首次自动后台拉取,无需确认)
>>> 5 GiB / (100 Mbit/s)      # 下载要多久 → 自动得出时间量纲
>>> atan2(30 cm, 1 m) -> deg  # 三角函数 + 角度
>>> c                         # 内置物理常数(光速等)
```

一次性模式:`numbat -e "表达式"`。

### 可编程(比 qalc 强的地方)

```
>>> let rate = 7.2 CNY / USD          # 定义带单位的变量
>>> 3999 CNY / rate                   # → USD
>>> fn tax(x: Money) = x * 0.13      # 定义函数
>>> unit jin: Mass = 500 g            # 定义自己的单位:斤
>>> 3 jin -> kg                       # 1.5 kg
```

把常用定义写进 `~/.config/numbat/init.nbt`,每次启动自动加载。

---

## 怎么选

- **换汇率、随手一算** → `qalc "…"`(一次性,最快)
- **连续推演、科学/工程计算、怕单位弄错** → `numbat` REPL
- **想要图形界面/翻历史** → 启动台里的 qalculate-qt(和 qalc 共享引擎与汇率缓存)
- 系统自带的 Spotlight(⌘Space 输 `100 usd in cny`)适合最轻量的场景

## 备忘

- 两者的汇率都来自公开数据源(ECB 档),**只是参考中间价**,和银行/交易所
  实际牌价有差,别拿去对账。
- qalc 的汇率缓存与 GUI 版共享;numbat 独立缓存,离线时用最后一次数据。
