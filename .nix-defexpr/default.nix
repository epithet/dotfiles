with import <nixpkgs> {};
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
      lsd bat ripgrep ripgrep-all fd
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

      firefox surf w3m lynx # elinks browsh (jumanji?)
      neomutt # aerc
      urlscan
      (runCommand "neomutt-pgpewrap" {} ''
        mkdir -p $out/bin
        cp ${neomutt}/libexec/neomutt/pgpewrap $out/bin
      '')
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
        TERM=screen-256color ${tmux}/bin/tmux -f ${writeTextFile {
          name = "tmux.conf";
          text = with tmuxPlugins; ''
            set-option -ga terminal-overrides ",screen*:Tc"
            source-file ~/.config/tmux/tmux.conf
            run-shell ${sensible.rtp}
            run-shell ${nord.rtp}
          '';
        }} "$@"
      '')
      (runCommandLocal "tmux-rest" {} ''
        mkdir -p $out
        for d in ${tmux}/*; do
          if [ $(basename $d) != bin ]; then
            cp -r $d $out/
          fi
        done
      '')
      tmux.man

      neovim
      (runCommandLocal "vi-link" {} ''
        mkdir -p $out/bin
        ln -s ${neovim}/bin/nvim $out/bin/vi
      '')
      neovide
      (vimUtils.packDir({
        myNvimPlugins = {
          start = with vimPlugins; [
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
      nodejs

      gitui tig
      git-ftp
      meld

      gnumake

      dfeet

      pandoc
      zettlr

      restic
      pass pass-git-helper
      gnupg

      wmctrl
      gebaar-libinput

      mate.engrampa
      zip unzip
      p7zip

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
