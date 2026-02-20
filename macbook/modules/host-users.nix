{
  username,
  hostname,
  ...
} @ args:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  # NOTE: smb.NetBIOSName is removed because macOS SIP blocks writes to
  # /Library/Preferences/SystemConfiguration/com.apple.smb.server
  # Set NetBIOS name manually via: System Settings > General > Sharing
  # system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };
  system.primaryUser = username;

  nix.settings.trusted-users = [username];
}