{
  description = "A Neovim plugin and CLI tool for tracking food macros";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # To import an internal flake module: ./other.nix
        # To import an external flake module:
        #   1. Add foo to inputs
        #   2. Add foo as a parameter to the outputs function
        #   3. Add here: foo.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        # self',
        pkgs,
        ...
      }: {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "macros";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            lua
            makeWrapper
          ];

          # Skip the build phase (no compilation needed for Lua)
          dontBuild = true;

          installPhase = ''
            mkdir -p $out/bin $out/share/macros

            # Copy the lua modules
            cp -r lua $out/share/macros/

            # Copy the CLI script
            cp macros.lua $out/share/macros/

            # Create a wrapper script that sets up the correct paths
            makeWrapper ${pkgs.lua}/bin/lua $out/bin/macros \
              --add-flags "$out/share/macros/macros.lua"
          '';

          meta = {
            description = "CLI tool for looking up food macros";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.unix;
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            lua
            luajitPackages.luacheck
            stylua
          ];
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

        overlays.default = final: prev: {
          macros = self.packages.${final.stdenv.hostPlatform.system}.default;
        };
      };
    };
}
