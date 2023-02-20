{
  description = "An example Rust development environment";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      rec {

        # define the default development shell environment
        devShells.default = pkgs.mkShell {

          # all of the tools we want to be available in our environment
          packages = with pkgs; [
            cargo
            cargo-edit
            cargo-outdated
            clippy
            rustc
            rustfmt
            rust-analyzer

            # plotters dependencies
            cmake
            fontconfig
            pkg-config

            # formatter for flakes
            nixpkgs-fmt
          ];

          # set an environment variable for the standard library path
          # required for rust-analyzer
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        };
      });
}
