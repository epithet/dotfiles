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
