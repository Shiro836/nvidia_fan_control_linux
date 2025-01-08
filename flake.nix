{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
                allowUnfree = true;
                segger-jlink.acceptLicense = true;
                acceptCudaLicense = true;
                cudaSupport = true;
                cudaVersion = "12";
            };
            inherit (pkgs.cudaPackages) cudatoolkit;
            inherit (pkgs.linuxPackages) nvidia_x11;
        };

        pythonEnv = pkgs.python311.withPackages (p: with p; [
          pynvml
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
          ];

          shellHook = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib
          '';
        };
      }
    );
}