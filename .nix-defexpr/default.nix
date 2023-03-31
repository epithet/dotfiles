with import <nixpkgs> {}; [

  alacritty # sakura wezterm foot
  (writeShellScriptBin "gnome-terminal" ''
    # https://gitlab.xfce.org/xfce/exo/-/issues/99
    # https://gitlab.freedesktop.org/xdg/xdg-specs/-/issues/54
    # https://github.com/Vladimir-csp/xdg-terminal-exec
    shift
    exec exo-open --launch TerminalEmulator "$@"
  '')
  tab-rs zellij
  starship
  exa lsd bat ripgrep ripgrep-all fd
  procs htop lsof # lsof needed for htop 'l'
  file
  progress
  tldr
  jq
  mdcat
  binutils # strings needed for less (binary files)
  bubblewrap
  xclip # needed for neovim "+y and "+p

  rofi
  rofimoji
  xfce.xfdashboard

  firefox surf # w3m lynx elinks browsh (jumanji?)
  zathura
  # mutt aerc
  vlc

  gnome.simple-scan

  (vimUtils.packDir({
    myNvimPlugins = {
      start = with vimPlugins; [
        vim-nix
        nvim-lspconfig
      ];
    };
  }))
  rnix-lsp
  sumneko-lua-language-server
  clang-tools
  rust-analyzer cargo rustc
  lldb

  gitui tig
  git-ftp
  meld

  zettlr

  restic
  pass pass-git-helper
  gnupg

  wmctrl
  gebaar-libinput

]
