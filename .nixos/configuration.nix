# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      <nixos-hardware/lenovo/thinkpad/x1/10th-gen>
      ./hardware-configuration.nix # Include the results of the hardware scan.
    ];

  boot.kernelPackages = pkgs.linuxKernel.packageAliases.linux_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixda"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # TLP
  services.tlp = {
    enable = true;
    # run `tlp-stat -c` to view current settings
    settings = {
      START_CHARGE_THRESH_BAT0 = "75";
      STOP_CHARGE_THRESH_BAT0 = "80";
      # performance mode can be changed with keyboard shortcuts:
      # - Fn+l - low-power
      # - Fn+m - balanced
      # - Fn+h - performance
      # current mode can be viewd with
      # `cat /sys/firmware/acpi/platform_profile`
      PLATFORM_PROFILE_ON_BAT = "low-power";
      PLATFORM_PROFILE_ON_AC = "low-power";
      # the WWAN chip currently has issues with runtime power management
      # and will prevent booting if runtime-pm is enabled for the device.
      # To exclude it, modify the tlp configuration like:
      #RUNTIME_PM_DENYLIST="08:00.0"
    };
  };

  services.gpm.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.videoDrivers = [ "intel" ];
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.slick.enable = true;
  services.xserver.displayManager.lightdm.greeters.slick.iconTheme.name = "Numix";
  services.xserver.displayManager.lightdm.greeters.slick.extraConfig = ''
    show-hostname=false
    show-power=true
    show-keyboard=true
    show-clock=true
    show-quit=true
    clock-format=%F | %a | wk%V | %T
  '';
  services.xserver.displayManager.defaultSession = "xfce";
  services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.desktopManager.xfce.thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ];
  programs.thunar.plugins = [ pkgs.xfce.thunar-archive-plugin ];

  fonts = {
    #enableFontDir = true;
    #enableGhostscriptFonts = true;
    fonts = with pkgs; [
      #corefonts # unfree
      dejavu_fonts
      #fira fira-go fira-mono fira-code fira-code-symbols
      (nerdfonts.override { fonts = [
        "DejaVuSansMono"
        "DroidSansMono"
        "FantasqueSansMono"
        "FiraCode"
        "Inconsolata"
        "JetBrainsMono"
        "UbuntuMono"
      ]; })
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
  };

  # Configure keymap in X11
  services.xserver.layout = "us,de";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp,grp:alt_shift_toggle,eurosign:e";
    # "caps:escape" # map caps to escape.

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # IPP everywhere capable printers
  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;
  # for a WiFi printer
  #services.avahi.openFirewall = true;
  # Samsung proprietary
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (pkgs.lib.getName pkg) [
      "samsung-UnifiedLinuxDriver"
    ];

  # Enable SANE to scan documents.
  hardware.sane.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.seb = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "lp" "scanner"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget curl
    git
    xorg.xkill # : Ctrl+Alt+Esc
    onboard # xfce4-screensaver-preferences > Lock Screen > On Screen Keyboard
    brightnessctl redshift # acpilight light
    numix-icon-theme
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true; # environment.variables.EDITOR = "nvim";
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set ts=4 sw=4 sts=0 smarttab expandtab autoindent
        if filereadable(expand("~/.config/nvim/init.vim"))
          source ~/.config/nvim/init.vim
        endif
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
        ];
        opt = [
          vim-nix
        ];
      };
    };
  };

  # remove weird default aliases from /etc/bashrc
  environment.shellAliases = { l = null; ll = null; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

