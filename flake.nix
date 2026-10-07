{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      projectName = "BasicShell"; # FIXME: Name of the software / product bundled here
      version = "1.0.0"; # FIXME: Version strategy
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          lib,
          system,
          ...
        }:
        let

          mkPackage =
            {
              debug ? false,
            }:
            pkgs.buildGoModule {
              src = ./.;
              name = projectName;
              inherit version;

              vendorHash = lib.fakeHash;

              ldflags = [
              ]
              ++ lib.optionals (!debug) [
                "-s"
                "-w"
              ];

              # If checks require network access, they need to be disabled. You dont need to disable all checks though!
              excludedPackages = [ ];
              doCheck = true;

              meta = { };
            };

          pkgsPackages = with pkgs; [
            # FIXME: add pkgs packages here
            go
          ];
          packages = [
            # FIXME: add packages you defined here
          ]
          ++ pkgsPackages;

          # These packages are only used as development tools - they are not required for building your packages
          devPackages = [
            pkgs.gopls
            pkgs.delve
          ];

        in
        {
          packages = {
            default = mkPackage { };
            default-debug = mkPackage { debug = true; };
          };
          devShells.default = pkgs.mkShell {
            name = "${projectName}-devshell";
            packages = packages ++ devPackages;
          };
        };
      flake = {
      };
    };
}
