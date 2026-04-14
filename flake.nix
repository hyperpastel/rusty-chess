
{
  description = "Nix development flake for <project_name>";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      rust-overlay,
      ...
    }:

    utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        devShells = {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                rust
                cargo-nextest
                mold
                openssl
                pkg-config
                cmake

                binutils

                # OpenGL
                libGL
                libGLU
                mesa

                # X11
                xorg.libX11
                xorg.libXrandr
                xorg.libXinerama
                xorg.libXcursor
                xorg.libXi

                # bindgen
                llvmPackages.libclang
              ];

              shellHook = ''
                echo Entered Rust dev shell for project
                export PROJECT_PREFIX=rust
                export LIBCLANG_PATH="${pkgs.llvmPackages.libclang.lib}/lib"
                export RAYLIB_CMAKE_ARGS="-DUSE_WAYLAND=ON"
              '';
            };
        };
      }
    );

}
