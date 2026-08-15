{pkgs, ...}: {
  # 声明式配置 ~/.ssh/config
  #
  # 2026-08-13 语法现代化 (对照 home-manager 钉定版的 modules/programs/ssh.nix):
  #   · `settings` 是现行写法 (matchBlocks 已标废弃并映射到它), 结构保留;
  #   · 键名改用 ssh_config 上游原生大小写 (User/IdentityFile/...) —— 模块文档
  #     要求 "upstream directive names"; 小写也能跑 (ssh 不分大小写) 但非规范;
  #   · enableDefaultConfig 旧缺省垫片"将来会废弃", 按模块给的等价片段显式写成
  #     settings."*", 不再吃隐式缺省。
  programs.ssh = {
    enable = true;
    # 强制安装 Nix 提供的原汁原味的完整版 OpenSSH（自带 FIDO2 支持）
    # 覆盖默认的 null（如果不写这行，macOS 默认会去调用自带的阉割版 /usr/bin/ssh，导致报错）
    package = pkgs.openssh;

    # 敏感的 HostName/IP 继续留在仓库外的 include 文件里
    includes = ["~/.ssh/config.d/hosts"];

    enableDefaultConfig = false;

    settings = {
      # 显式写出原 enableDefaultConfig 的缺省 (模块注释给的等价片段)
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "tokyo" = {
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519_sk";
        ServerAliveInterval = 4;
        ServerAliveCountMax = 30;
        # 部署便利: id_ed25519_sk 是 FIDO2 钥匙, 每条新连接都要 YubiKey 触碰。
        # 复用主通道后, 一次触碰 10 分钟内的 rsync/ssh 全部免碰 ——
        # 部署脚本连打十几条命令靠的就是这个。
        ControlMaster = "auto";
        ControlPersist = "10m";
      };

      "us" = {
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519_sk";
        ServerAliveInterval = 4;
        ServerAliveCountMax = 30;
      };

      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_sk";
        ServerAliveInterval = 4;
        ServerAliveCountMax = 30;
      };
    };
  };
}
