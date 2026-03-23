{ config, pkgs, ... }:

let
  # Use your specific path
  dotfiles = "/home/chiyuki/nixos-wujie-15x-pro/out-of-store-symlinks/";
  createSimlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in

{
  home.username = "chiyuki";
  home.homeDirectory = "/home/chiyuki";
  home.stateVersion = "25.11";


  # Software
  home.packages = with pkgs; [
    kdePackages.kdenlive
    joplin-desktop
    sqlitebrowser
    xournalpp
    krita
    texliveMedium
    mission-center
    syncthing
    chromium
    ppsspp
    obs-studio
    gimp
    upscayl
    onlyoffice-desktopeditors
  ];


  programs.vscode = {
    enable = true;
    package = pkgs.vscodium; # The open-source version

    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Python (The core extension is OSS, but we skip Pylance)
      ms-python.python
      ms-python.debugpy
      detachhead.basedpyright

      # Jupyter
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter-keymap
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags

      # C++ (Switching to the superior open-source engine)
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools

      # Nix (Essential for your Flakes)
      mkhl.direnv
      jnoortheen.nix-ide

      # Speller & Utils
      streetsidesoftware.code-spell-checker
      james-yu.latex-workshop
      mechatroner.rainbow-csv
      shd101wyy.markdown-preview-enhanced

    ];
  };


  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };


  xdg.configFile = {
    "VSCodium/User/settings.json".source = createSimlink "vscodium/settings.json";
  };


  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Haoting Chen";
        email = "u7227871@anu.edu.au";
      };
    };
  };


  programs.bash = {
    enable = true;
    shellAliases = {
      me = "echo 'Chiyuki!'";
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-wujie-15x-pro#chiyuki-nanami";
      python = "python3";
      activate-kt = "nix develop ~/nixos-config/python-envs/kt";
      activate-base = "nix develop ~/nixos-config/python-envs/base";
      hypr = "start-hyprland";
    };
    bashrcExtra = ''
      export PATH="$HOME/.local/bin:$PATH"

      # The NixOS way: Only echo if the shell is interactive
      if [[ $- == *i* ]]; then
        echo "Welcome back, chiyuki!"
      fi
    '';
  };
}
