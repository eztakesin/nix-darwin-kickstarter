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

      # 只读、免触碰的钥匙, 给无人值守的定时同步用。远端 authorized_keys
      # 把它限制为对单个目录的只读 rsync (rrsync -ro): 写入和 shell 都会被
      # 拒绝 (已实测)。
      "tokyo-ro" = {
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519_outerloop";
        IdentitiesOnly = true;
        ControlMaster = "no";
        ControlPath = "none";
      };

      # 同一台 tokyo, 换一把不需要触碰的钥匙, 给一条无人值守的端口转发
      # 隧道用 (由机器本地的模块启动, 不在本仓库)。
      #
      # 为什么非要另起别名, 而不是给 tokyo 命令行加 -i: IdentitiesOnly=yes
      # 只排除 **agent 递过来的**钥匙, 挡不住 ssh_config 里 IdentityFile
      # 声明的那把。于是 tokyo 块的 id_ed25519_sk 照样被优先试 —— 拔了
      # YubiKey 报 "device not found", 插着则**阻塞等触碰**。无人值守的
      # 隧道两种都要不起, 而这是实测踩出来的, 不是理论顾虑。
      #
      # HostName 照旧留在仓库外: 在 ~/.ssh/config.d/hosts 里把那行写成
      # `Host tokyo tokyo-feed tokyo-ro` 即可, 几个别名共用同一个 IP。
      #
      # 远端那把公钥是被剥过权的 (authorized_keys): restrict 加上只放行
      # 一个本地端口的 permitopen, 再配 permitlisten 和 nologin, 所以明文
      # 无密码落盘是可接受的取舍。
      #
      # permitlisten 别删: `port-forwarding` 一次发还**两个**方向, 而
      # permitopen 只管 -L; 少了它 -R 对任意端口敞开 (实测补上的)。
      "tokyo-feed" = {
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519_feedtunnel";
        IdentitiesOnly = true;
        # 必须独占控制通道。与 tokyo 共用会让交互式 `ssh tokyo` 复用到这条
        # 受限连接上, 每条命令都撞 nologin —— 一个查起来很费劲的故障。
        ControlMaster = "no";
        ControlPath = "none";
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
