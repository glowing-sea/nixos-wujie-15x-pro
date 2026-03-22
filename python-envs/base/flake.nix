{
  description = "Python Base Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
        };
      };
    in
    {
      # This replaces shell.nix
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (python3.withPackages (ps: with ps; [
            numpy
            pandas
          ]))
        ];

        shellHook = ''
          echo "Entering Base Environment..."
          python --version

          # Add (env name) to the left of the prompt
          # export PS1="\[\e[1;32m\](kt)\[\e[0m\] ''${PS1#\\n}"
          # Color Key:
          # (base)   = Bold Green  \[\e[1;32m\]
          # user@host = Cyan        \[\e[0;36m\]
          # directory = Bold Yellow \[\e[1;33m\]
          # Reset     = Normal      \[\e[0m\]
          export PS1="\[\e[1;32m\](base) \[\e[0;36m\][\u@\h:\[\e[1;33m\]\w\[\e[0;36m\]]\$ \[\e[0m\]"
          export IN_NIX_SHELL="base"

        '';
      };
    };
}
