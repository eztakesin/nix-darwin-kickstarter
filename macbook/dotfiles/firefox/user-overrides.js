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
user_pref("font.cjk_pref_fallback_order", "ja,zh-cn,zh-hk,zh-tw");
user_pref("font.name.sans-serif.zh-CN", "Source Han Sans SC");
user_pref("font.name.serif.zh-CN", "Source Han Serif SC");
user_pref("font.name.monospace.zh-CN", "Sarasa Mono SC");


user_pref("_my_overrides.parrot", "END: user-overrides.js loaded");
