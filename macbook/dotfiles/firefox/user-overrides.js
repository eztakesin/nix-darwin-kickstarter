/***********************************************************
 * user-overrides.js (arkenfox user.js overrides)
 *
 * Privacy/anti-fingerprinting priority: RFP + disable WebRTC + disable WebGL
 * Performance/compatibility: JS JIT on, WASM on, Service Worker on
 * Push notifications disabled
 *
 * Apply after each edit:
 * 1) Close Firefox
 * 2) In profile root: ./updater.sh && ./prefsCleaner.sh
 * 3) Start Firefox
 *
 * Verify: about:config search _my_overrides.parrot
 ***********************************************************/

user_pref("_my_overrides.parrot", "START: user-overrides.js loaded");


/*** ========== 0100 Startup ========== */
user_pref("browser.startup.page", 3);


/*** ========== 密码 / 自动填充:全部关闭 ========== */
// arkenfox 默认已关 signon.autofillForms(339 行)和 formlessCapture(341 行),
// 但把下面这些放在可选区注释着。密码/地址/卡号由外部管理,浏览器不掺和。
// 注:关闭 rememberSignons 只是不再询问/保存新密码,已保存的条目仍在。
user_pref("signon.rememberSignons", false); // 不再询问保存密码
user_pref("signon.generation.enabled", false); // 不建议生成强密码
user_pref("extensions.formautofill.addresses.enabled", false); // 不保存/填充地址
user_pref("extensions.formautofill.creditCards.enabled", false); // 不保存/填充卡号


// Firefox Relay 邮箱别名建议:不需要(邮箱别名在 Proton/Fastmail 侧管理)
user_pref("signon.firefoxRelay.feature", "disabled");


/*** ========== GPC(Global Privacy Control) ========== */
// 发送 "不要出售/共享我的数据" 信号(Sec-GPC 请求头 + navigator API)。
// 注意:arkenfox 特意把它注释掉(7021),理由是该信号本身构成指纹特征,
// 且拦截效果与已启用的 ETP Strict 大致重叠。这里仍然开启,因为 GPC 在
// CCPA/CPRA 等法域具有法律约束力 —— 那是纯技术拦截拿不到的东西。
user_pref("privacy.globalprivacycontrol.enabled", true);


/*** ========== 遥测:补上 arkenfox 的缺口 ========== */
// arkenfox 的 0300 段已经关掉了绝大部分:技术与交互数据
// (datareporting.policy/healthreport)、整套 toolkit.telemetry.*、
// 扩展推荐(browser.discovery)、功能实验(app.shield.optoutstudies)、
// 远程功能推送(app.normandy)、崩溃报告(breakpad + crashReports)。
// 下面两条是它(144 版)还没收录的较新遥测通道:
user_pref("datareporting.usage.uploadEnabled", false); // 每日活跃用户 ping
user_pref("browser.ping-centre.telemetry", false); // ping-centre(新标签页等)


/*** ========== 关闭内置 VPN(IP Protection) ========== */
// Mozilla 的内置 VPN。关掉它同时会把工具栏上那个 VPN 按钮一并移除,
// 不需要额外的 userChrome.css 规则。
// 本机流量本来就走 ProtonVPN,不需要浏览器再套一层(套了反而多一个
// 需要信任的第三方,以及和现有隧道打架的可能)。
user_pref("browser.ipProtection.enabled", false);


/*** ========== 关闭 AI 功能 ========== */
// arkenfox 尚未覆盖这些(功能太新)。关掉 AI 标签分组建议和侧边栏聊天机器人。
// 注意:没有动 browser.ml.enable 这个总开关 —— 内置翻译也走本地 ML 栈,
// 一刀切可能把刚配好的翻译一起关掉。要彻底禁用再单独评估。
user_pref("browser.tabs.groups.smart.enabled", false); // AI 建议标签分组/命名
user_pref("browser.ml.chat.enabled", false); // 侧边栏 AI 聊天


/*** ========== 内置翻译 ========== */
// Firefox 的翻译在本地运行(模型下载到本机,不上传页面内容)。
// 总是翻译:泰语、越南语、德语、西班牙语、法语 + 北欧语系
// (丹麦语 da、瑞典语 sv、挪威语 nb、芬兰语 fi、冰岛语 is)
user_pref("browser.translations.alwaysTranslateLanguages", "th,vi,de,es,fr,da,sv,nb,fi,is");
// 从不翻译:中文(简/繁)、日语、英语 —— 看得懂,不需要
user_pref("browser.translations.neverTranslateLanguages", "zh-Hans,zh-Hant,ja,en");


/*** ========== 动效与链接样式 ========== */
// 始终给链接加下划线:不依赖颜色区分链接,对色觉和扫读都友好
user_pref("layout.css.always_underline_links", true);
// 平滑滚动(Firefox 默认已开,这里显式固定,避免以后默认值变化)
user_pref("general.smoothScroll", true);


/*** ========== 界面密度 ========== */
// 0=Standard, 1=Compact, 2=Touch。设置面板里的 "Window density"。
// 若发现不生效(新版设置界面可能换了 pref),在界面里点一次 Compact 后
// 到 about:config 查实际改动的键名。
user_pref("browser.uidensity", 1);


/*** ========== userChrome.css ========== */
// Firefox only reads <profile>/chrome/userChrome.css when this is true —
// it defaults to false and arkenfox does not set it, which is why the
// hand-written tab-hiding CSS in the profile never took effect.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);


/*** ========== Theme ========== */
// "Trans Pride by Miri" (Marion Daly), addons.mozilla.org/addon/trans-pride-by-miri/
// The XPI itself is installed through AMO — dropping it into the profile's
// extensions/ dir instead would land under extensions.autoDisableScopes
// (default 15) and stay disabled, and lowering that pref to work around it
// would weaken arkenfox's anti-sideloading stance for a cosmetic add-on.
// Pinning the ID here keeps the *selection* declarative: reinstall the theme
// on a fresh profile and it is picked automatically.
// NOTE: because user.js re-applies every startup, switching themes from the
// Firefox UI will not stick — change this line instead.
user_pref("extensions.activeThemeID", "{cc29223b-6794-43bb-9dfb-54487bef733a}");


/*** ========== 0700 DNS / DoH: delegate to system (Stash/Clash) ========== */
user_pref("network.trr.mode", 5);
user_pref("network.trr.uri", "");
user_pref("network.trr.custom_uri", "");


/*** ========== 0700 Proxy bypass ========== */
user_pref("network.proxy.allow_bypass", false);


/*** ========== 1200 HTTPS-Only & local dev ========== */
user_pref("dom.security.https_only_mode.upgrade_local", false);
user_pref("security.mixed_content.block_display_content", true);


/*** ========== 1700 Container tabs ========== */
user_pref("privacy.userContext.newTabContainerOnLeftClick.enabled", true);


/*** ========== 2700 Anti-tracking (strict) ========== */
user_pref("privacy.antitracking.enableWebcompat", false);


/*** ========== 4500 RFP (core anti-fingerprinting) ========== */
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.resistFingerprinting.letterboxing", true);
user_pref("privacy.spoof_english", 2);
user_pref("privacy.resistFingerprinting.exemptedDomains", "");


/*** ========== 2000 WebRTC: disabled ========== */
user_pref("media.peerconnection.enabled", false);


/*** ========== 4520 WebGL: disabled ========== */
user_pref("webgl.disabled", true);


/*** ========== 7000 Modern web ========== */
user_pref("dom.serviceWorkers.enabled", true);
user_pref("dom.push.enabled", false);
user_pref("dom.webnotifications.enabled", false);


/*** ========== Performance ========== */
user_pref("gfx.webrender.all", true);
user_pref("fission.autostart", true);
user_pref("javascript.options.ion", true);
user_pref("javascript.options.baselinejit", true);
user_pref("javascript.options.wasm", true);


/*** ========== 2800 Clear on shutdown ========== */
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.downloads", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
user_pref("privacy.sanitize.timeSpan", 0);


/*** ========== 0800 URL Bar ========== */
user_pref("browser.urlbar.clipboard.featureGate", false);
user_pref("browser.urlbar.recentsearches.featureGate", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.maxRichResults", 0);
user_pref("browser.urlbar.autoFill", false);
user_pref("keyword.enabled", false);
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("sidebar.revamp", false);


/*** ========== Font preferences ========== */
// Default language group for documents that declare no language: Western,
// so ambiguous/undeclared pages get Latin fonts and metrics rather than
// being treated as CJK.
user_pref("font.language.group", "x-western");
// When content *is* CJK but its regional variant is ambiguous, prefer
// Simplified Chinese orthography. (Han unification: 骨/直/令 etc. share
// codepoints across zh/ja but have different standard glyph shapes — this
// list decides which convention wins when the page doesn't say.) Pages
// that correctly declare lang="ja" are still rendered as Japanese.
user_pref("font.cjk_pref_fallback_order", "zh-cn,zh-hk,zh-tw,ja");
// Noto Sans/Serif CJK == Source Han Sans/Serif (same typefaces, different
// family names); the Source Han packages were dropped because MS Office
// cannot parse their CFF-collection format.
// Switched from the nix-installed Noto CJK / Sarasa Mono to macOS system
// fonts: RFP limits web content to the bundled "Base Fonts" set (bugs
// 1653987 / 1826408 / 1787790), so self-installed families would just be
// substituted away — naming fonts that cannot be used is misleading.
// PingFang SC ~ Noto Sans CJK SC, Songti SC ~ Noto Serif CJK SC. macOS
// ships no CJK monospace at all (Sarasa Mono's Iosevka-Latin + exactly
// 2x-width CJK has no system counterpart), so CJK in code contexts falls
// back to PingFang SC — consistent, just not monospaced.
// NOTE: this only changes Firefox's web rendering. The Noto CJK OTF /
// Sarasa packages stay installed via fonts.packages and are still what
// MS Office and everything else use.
user_pref("font.name.sans-serif.zh-CN", "PingFang SC");
user_pref("font.name.serif.zh-CN", "Songti SC");
user_pref("font.name.monospace.zh-CN", "PingFang SC");


user_pref("_my_overrides.parrot", "END: user-overrides.js loaded");
