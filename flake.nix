{
  description = "Nix development flake for rusty chess";

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
                mesa

                # bindgen
                llvmPackages.libclang
              ];

              LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
                # OpenGL
                libGL
                libGLU

                # X11
                libX11
                libXrandr
                libXinerama
                libXcursor
                libXi
              ];

              shellHook = ''
                export LIBCLANG_PATH="${pkgs.llvmPackages.libclang.lib}/lib"
                export RAYLIB_CMAKE_ARGS="-DUSE_WAYLAND=ON"
              '';
            };
        };
      }
    );

}
