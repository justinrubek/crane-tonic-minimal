{
  description = "crane tonic example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-utils,
    flake-parts,
    fenix,
    ...
  }@inputs:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = flake-utils.lib.defaultSystems;

      perSystem = {
        config,
        pkgs,
        system,
        inputs',
        ...
      }: let
        toolchain = inputs'.fenix.packages.minimal.toolchain;

        craneLib = inputs.crane.lib.${system}.overrideToolchain
          toolchain;
      in rec {
        packages = {
          default = craneLib.buildPackage {
            src = ./.;

            buildInputs = [ pkgs.protobuf ];

            PROTOC = "${pkgs.protobuf}/bin/protoc";
            PROTOC_INCLUDE = "${pkgs.protobuf}/include";
          };
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              toolchain
            ];
          };
        };
      };

    };
}
