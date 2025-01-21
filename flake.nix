{
  description = "Meshtastic firmware build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # PlatformIO and Python dependencies
            platformio
            python3
            python3Packages.pip
            python3Packages.setuptools
            python3Packages.poetry-core

            # Build tools
            gcc
            gcc-arm-embedded
            pkg-config
            protobuf
            nanopb

            # Required libraries
            libusb1
            openssl
            bluez
            libyaml
            xorg.libX11
            xorg.libXi
            libinput
            libxkbcommon
            libgpiod

            # For TFT/UI development
            xorg.libX11
            xorg.libXi
            libinput
            libxkbcommon
          ];

          shellHook = ''
            # Ensure local Python environment
            python -m venv .venv
            source .venv/bin/activate
            
            # Update pip and install requirements
            pip install -U pip
            pip install -U "setuptools<72"
            pip install -U platformio adafruit-nrfutil
            pip install -U poetry-core
            pip install -U meshtastic --pre

            # Set library paths for X11 and input libraries
            export LD_LIBRARY_PATH="${pkgs.xorg.libX11}/lib:${pkgs.libinput}/lib:${pkgs.libxkbcommon}/lib:$LD_LIBRARY_PATH"
            
            echo "Meshtastic development environment ready!"
          '';
        };
      }
    );
}
