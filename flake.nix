{
  description = "A basic flake for my Bevy Game";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # Optional: use external flake logic, e.g.
        # inputs.foo.flakeModules.default
      ];
      flake = {
        # Put your original flake attributes here.
      };
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        # self',
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = with pkgs; [
            lua
            luajitPackages.luacheck
            stylua
          ];
        };
      };
    };
}
