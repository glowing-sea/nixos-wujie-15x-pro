{ config, pkgs, unstable, ... }:
{
  imports = [ ./hardware-configuration.nix ];


  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # Boot
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.resumeDevice = "/dev/disk/by-uuid/52683222-d6e4-4f88-a4dc-f361710279f5";
  boot.kernelParams = [
    "resume_offset=18419909"
  ];


  # Swap
  zramSwap.enable = true;
  swapDevices = [
    # If it is there, NixOS will just use it.
    # If it wasn't there, NixOS could create it if 'size = 16384;' is added.
    {device = "/swap/swapfile";}
  ];


  # GPU
  hardware.graphics = {
    enable = true;  # Should be enabled implicitly by DE
    enable32Bit = true;
  };
  # Ensure the GPU memory is mapped and ready before any services (into RAM disk)
  hardware.amdgpu.initrd.enable = true;


  # Games (Permissions for the hardware)
  hardware.steam-hardware.enable = true;


  # Network
  networking.hostName = "chiyuki-nanami";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.openssh = {
    enable = true;
    # Ensure the SFTP subsystem is explicitly enabled
    allowSFTP = true;
    settings = {
      # Sometimes Dolphin struggles if PasswordAuthentication is off
      # unless you have your SSH keys perfectly mapped in ~/.ssh/config
      PasswordAuthentication = true;
      PermitRootLogin = "no"; # Optional, Explicit
    };
  };


  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" "virbr0" ];
    allowedUDPPorts = [ config.services.tailscale.port ]; # tailscale
    allowedTCPPorts = [ 1234 ]; # nc
  };


  # VPN
  services.tailscale.enable = true;
  # Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled = {
    serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=nftables" ];
  };
  # Optimization: Prevent systemd from waiting for network online
  # Optional but recommended for faster boot with VPNs
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
  # [!! Added Elsewhere]: networking.nftables.enable = true;
  # [!! Added Elsewhere]: networking.firewall.enable = true;
  # [!! Added Elsewhere]: networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # [!! Added Elsewhere]: networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];


  # GNUPG# Enable the GnuPG agent with support for a GUI pinentry
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt; # Provides a native dialog box.
  };


  # Audio & Printing
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  

  # Desktop Environment
  services.xserver.enable = true;
  services.displayManager = {
    sddm.enable = true;
    # Enable autologin
    # defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = "chiyuki";
    };
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "au"; variant = ""; }; # keymap in x11  


  # Essential System Tools
  services.flatpak.enable = true;
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    nil
    lsd
    neovim
    wget
    pciutils
    fastfetch
    black  # Python Formatter
    vlc
    ffmpeg
    nvtopPackages.amd  # Task Monitor
    qdiskinfo
    kdiskmark
    hunspell  # Spelling Check
    hunspellDicts.en_US
    hunspellDicts.en_AU
    libreoffice-qt-fresh
    python3
    cryptsetup

    # C
    cmake
    ninja
    llvmPackages.clang  # Provides 'clang' and 'clang++'
    llvmPackages.bintools  # Provides 'ld' (the linker)
    clang-tools # Provides 'clangd' (LSP) and 'clang-format'

    # KDE
    kdePackages.kate  # (Implicitly Enabled)
    kdePackages.elisa  # (Implicitly Enabled)
    kdePackages.sddm-kcm  # SDDM Configuration (View Only)
    kdePackages.partitionmanager
    kdePackages.kcalc
    kdePackages.kclock
    kdePackages.kolourpaint
    kdePackages.kmines
    kdePackages.krecorder
    kdePackages.dragon
  ];


  # Default APP
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };


  # Virtual Machine
  virtualisation.libvirtd.enable = true;  # libvirtd daemon
  programs.virt-manager.enable = true;  # Virt-Manager GUI
  # [!! Added Elsewhere]: networking.firewall.trustedInterfaces = [ "virbr0" ];
  # [!! Added Elsewhere]: users.users.chiyuki.extraGroups = [ "libvirtd" "kvm" ];
  virtualisation.waydroid.enable = true;


  # User
  users.users.chiyuki = {
    isNormalUser = true;
    description = "chiyuki";
    extraGroups = [ 
      "networkmanager" # Switch network without sudo
      "wheel"
      # "video" # give user direct access to video hardware devices or webcam
      # "render"
      "libvirtd" # for virtual machine
      "kvm" # virtual machine
    ];
  };


  # Locale
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };


  # Chinese Input
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ kdePackages.fcitx5-chinese-addons fcitx5-gtk ];
  };
  

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # English font FIRST, then CJK as the fallback
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
      sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
      monospace = [ "Noto Sans Mono" "Noto Sans Mono CJK SC" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };


  # AI
  services.ollama = {
    enable = true;
    package = unstable.ollama-rocm;
    host = "0.0.0.0";
    port = 11434;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "1m";
    };
  };


  # Flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.direnv.enable = true;
  nix.registry.kt.to = {
    type = "path";
    path = "/home/chiyuki/nixos-wujie-15x-pro/python-envs/kt";
  };
  nix.registry.base.to = {
    type = "path";
    path = "/home/chiyuki/nixos-wujie-15x-pro/python-envs/base";
  };
  

  system.stateVersion = "25.11"; # Did you read the comment?
}

