with import <nixpkgs> {}; [

  alacritty # sakura wezterm foot
  tab-rs zellij
  starship
  exa lsd bat ripgrep ripgrep-all fd
  procs htop lsof # lsof needed for htop 'l'
  progress
  tldr
  jq
  mdcat
  binutils # strings needed for less (binary files)
  bubblewrap
  xclip # needed for neovim "+y and "+p

  rofi
  rofimoji

  firefox surf # w3m lynx elinks browsh (jumanji?)
  zathura
  # mutt aerc
  vlc

  gnome.simple-scan

  helix rust-analyzer lldb clang-tools rnix-lsp
  gitui
  git-ftp
  meld

  zettlr

  restic
  pass pass-git-helper
  gnupg

]
