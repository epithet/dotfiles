with import <nixpkgs> {};
let
  master = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/244a2f399fa62bea8580b6c8518e9a0d0603a383.tar.gz) {}; # 2023-04-24 → Neovim 0.9
in
{
  myPackages = buildEnv {
    name = "my-packages";
    paths = [

      (writeTextFile {
        name = "DefaultTerminalEmulator.desktop";
        text = ''
          [Desktop Entry]
          NoDisplay=true
          Version=1.0
          Encoding=UTF-8
          Type=X-XFCE-Helper
          Name=Default Terminal Emulator
          X-XFCE-Category=TerminalEmulator
          X-XFCE-Commands=${alacritty}/bin/alacritty
          X-XFCE-CommandsWithParameter=${alacritty}/bin/alacritty --command %s
          Icon=org.xfce.terminalemulator
        '';
        destination = "/share/xfce4/helpers/DefaultTerminalEmulator.desktop";
      })
      (writeShellScriptBin "gnome-terminal" ''
        # https://gitlab.xfce.org/xfce/exo/-/issues/99
        # https://gitlab.freedesktop.org/xdg/xdg-specs/-/issues/54
        # https://github.com/Vladimir-csp/xdg-terminal-exec
        shift
        exec exo-open --launch TerminalEmulator "$@"
      '')
      alacritty
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
      rlwrap
      libnotify # notify-send
      qrencode zbar

      rofi
      rofimoji
      xfce.xfdashboard

      firefox surf w3m lynx # elinks browsh (jumanji?)
      neomutt # aerc
      (writeTextFile {
        name = "NeoMutt.desktop";
        text = ''
          [Desktop Entry]
          NoDisplay=true
          Version=1.0
          Encoding=UTF-8
          Type=X-XFCE-Helper
          Name=NeoMutt
          X-XFCE-Category=MailReader
          X-XFCE-Binaries=neomutt;
          X-XFCE-Commands=exo-open --launch TerminalEmulator %B;
          X-XFCE-CommandsWithParameter=exo-open --launch TerminalEmulator ${python3Minimal}/bin/python3 ${xfce.xfce4-settings}/lib/xfce4/xfce4-compose-mail mutt %B "mailto:%s";
          Icon=applications-mail
        '';
        destination = "/share/xfce4/helpers/NeoMutt.desktop";
      })
      (let
        src = fetchFromGitLab {
          domain = "salsa.debian.org";
          owner = "debian";
          repo = "mailcap";
          rev = "debian/3.70";
          sha256 = "sha256-p85tQmHacoBwcjkxIc/Bc2hf89tWXTLijfwmQ9kmg54=";
        };
      in
      runCommand "run-mailcap" {} ''
        install -m u=rx -D -t $out/bin ${src}/run-mailcap
        substituteInPlace $out/bin/run-mailcap --replace "/usr/bin/perl" "${perl}/bin/perl"
        mkdir -p $out/share/man/man1
        gzip --stdout ${src}/run-mailcap.man >$out/share/man/man1/run-mailcap.1.gz
      '')

      zathura
      vlc mpv

      gnome.simple-scan

      tab-rs zellij
      (writeShellScriptBin "tmux" ''
        ${tmux}/bin/tmux -f ${writeTextFile {
          name = "tmux.conf";
          text = with tmuxPlugins; ''
            source-file ~/.config/tmux/tmux.conf
            run-shell ${sensible.rtp}
          '';
        }} "$@"
      '')

      master.neovim
      (runCommandLocal "vi-link" {} ''
        mkdir -p $out/bin
        ln -s ${master.neovim}/bin/nvim $out/bin/vi
      '')
      neovide
      (vimUtils.packDir({
        myNvimPlugins = {
          start = with master.vimPlugins; [
            vim-nix
            packer-nvim
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

      dfeet

      zettlr

      restic
      pass pass-git-helper
      gnupg

      wmctrl
      gebaar-libinput

      mate.engrampa
      zip unzip

      duc
      du-dust
      ncdu

    ];
    # cf. nixpkgs/nixos/modules/config/xdg/mime.nix
    postBuild = ''
      if [ -w $out/share/mime ] && [ -d $out/share/mime/packages ]; then
          XDG_DATA_DIRS=$out/share PKGSYSTEM_ENABLE_FSYNC=0 ${shared-mime-info}/bin/update-mime-database -V $out/share/mime > /dev/null
      fi
      if [ -w $out/share/applications ]; then
          ${desktop-file-utils}/bin/update-desktop-database $out/share/applications
      fi
    '';
  };
}
