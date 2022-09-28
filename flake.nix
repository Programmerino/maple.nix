{
  description = "Maple";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.maple-installer = {
    url = "/home/davis/Maple2022.1LinuxX64Installer.run";
    flake = false;
  };

  # https://wiki.archlinux.org/title/Maple Offline Activation
  inputs.license-dat = {
   url = "/home/davis/license.dat";
   flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    license-dat,
    flake-utils,
    maple-installer,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        installerLibPath = with pkgs;
          pkgs.lib.makeLibraryPath [
            glibc
          ];
        installerOpts = "--mode unattended --defaultapp 0 --defaulttoolbox Maple --enableUpdates 0 --checkForUpdatesNow 0";
      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "Maple";
          version = "0.0.1";
          dontUnpack = true;
          dontPatch = true;
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out
	    export HOME=$(mktemp -d)
	    chmod +w -R $HOME
            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --output maple-installer.run ${maple-installer}
            chmod +x maple-installer.run
            ./maple-installer.run ${installerOpts} --installdir $out
            ln -s ${license-dat} $out/license/license.dat
            rm $out/Maple_*.log
            rm $out/*.run
          '';

          autoPatchelfIgnoreMissingDeps = ["libgdbm.so.4" "libavcodec.so.56" "libavformat.so.56" "libavcodec.so.54" "libavformat.so.54" "libavcodec.so.57" "libavformat.so.57" "libavcodec-ffmpeg.so.56" "libavformat-ffmpeg.so.56" "libavcodec.so.57" "libavformat.so.57" "libmx.so" "libeng.so"];

          buildInputs = with pkgs; [
            alsa-lib
            ffmpeg
            bzip2
            cairo
            freetype
            gdbm
            gtk3-x11
            gdk-pixbuf
            gnome2.gtk
            glib
            libglvnd
            gcc-unwrapped.lib
            xorg.libICE
            xz
            ncurses5
            gnome2.pango
            readline
            xorg.libSM
            tcl-8_5
            tk-8_5
            libuuid.lib
            xorg.libX11
            xorg.libXcursor
            xorg.libXext
            xorg.libXi
            motif
            xorg.libXmu
            xorg.libXrandr
            xorg.libXrender
            xorg.libXt
            xorg.libXtst
            xorg.libXxf86vm
            zlib
          ];

          nativeBuildInputs = with pkgs; [autoPatchelfHook];
        };
        defaultPackage = packages.default;
        apps.default = flake-utils.lib.mkApp {drv = packages.default;};
        defaultApp = apps.default;
      }
    );
}
