{
  description = "An example Rust development environment";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        naersk' = pkgs.callPackage naersk { };

        # library / tool dependencies for runtime
        plottersBuildInputs = with pkgs; [ fontconfig ];
        # library / tool dependencies for build time
        plottersNativeBuildInputs = with pkgs; [ cmake pkg-config ];
        # bundled for the development shell for convenience
        plottersPackages = plottersBuildInputs ++ plottersNativeBuildInputs;
      in
      rec {
        # define a package using naersk to build the Rust code
        packages.nixRustWorkflow = naersk'.buildPackage {
          src = ./.;
          buildInputs = plottersBuildInputs;
          nativeBuildInputs = plottersNativeBuildInputs;
        };

        # define a docker image package that uses the naersk package
        packages.nixRustWorkflowDocker = pkgs.dockerTools.buildImage {
          name = "nix-rust-workflow";
          tag = "latest";

          # create a cache directory for fontconfig
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            mkdir -p /.cache/fontconfig
          '';

          config = {
            Env = [
              # define an environment variable that fontconfig expects
              "FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts"
            ];
            Cmd = [ "${packages.nixRustWorkflow}/bin/nix_rust_workflow" ];
          };
        };

        # set the default package to the Rust naersk one
        packages.default = packages.nixRustWorkflow;

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

            # formatter for flakes
            nixpkgs-fmt
          ] ++ plottersPackages;

          # set an environment variable for the standard library path
          # required for rust-analyzer
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        };
      });
}
