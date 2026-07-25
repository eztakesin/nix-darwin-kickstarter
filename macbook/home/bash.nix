{...}: {
  # Interactive bash for occasional use — fish is the login shell.
  # The module generates ~/.bashrc/.profile and wires nix's
  # bash-completion into it (enableCompletion defaults to true).
  # Replaces the bash-completion@2 brew, which was dead weight: the
  # package alone does nothing unless a bashrc sources it.
  programs.bash = {
    enable = true;
  };
}
