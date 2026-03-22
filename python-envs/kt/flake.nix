{
  description = "PyTorch CUDA Research Environment";

  inputs = {
    # Points to the official NixOS unstable or stable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Your architecture
      pkgs = import nixpkgs {
        inherit system;
        config = {
          # allowUnfree = false;
          rocmSupport = true;
        };
      };
    in
    {
      # This replaces shell.nix
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (python3.withPackages (ps: with ps; [

            # Project Environment
            numpy
            pandas
            matplotlib
            scikit-learn
            torch
            torchvision

            # Development Environment
            jupyter

          ]))
        ];

        shellHook = ''
          echo "Entering Flake-based Research Environment..."
          python --version
          python -c "import torch; \
          print(f'Device: {torch.cuda.get_device_name(0)}'); \
          print(f'Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f}GB')"

          # Add (env name) to the left of the prompt
          # export PS1="\[\e[1;32m\](kt)\[\e[0m\] ''${PS1#\\n}"
          # Color Key:
          # (base)   = Bold Green  \[\e[1;32m\]
          # user@host = Cyan        \[\e[0;36m\]
          # directory = Bold Yellow \[\e[1;33m\]
          # Reset     = Normal      \[\e[0m\]
          export PS1="\[\e[1;32m\](kt) \[\e[0;36m\][\u@\h:\[\e[1;33m\]\w\[\e[0;36m\]]\$ \[\e[0m\]"
          export IN_NIX_SHELL="kt"
        '';
      };
    };
}
