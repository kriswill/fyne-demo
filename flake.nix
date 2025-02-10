{
  description = "Fyne Demo application";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      overlay = _: prev: { inherit (self.packages.${prev.system}) fyne-demo; };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          fyne-demo = with pkgs; pkgs.buildGoModule rec {
            pname = "fyne-demo";
            version = "v2.5.3";
            src = ./.;

            vendorHash = "sha256-Ag5sAdIIdmKbkix+nupVIw3bqPx+3xYpddDRao/epzw=";

            nativeBuildInputs = [ pkg-config copyDesktopItems ];
            buildInputs = [
              glfw
              libGL
              libGLU
              openssh
              pkg-config
              glibc
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXxf86vm
              xorg.xinput
            ];

            desktopItems = [
              (makeDesktopItem {
                name = "traygent";
                exec = pname;
                icon = pname;
                desktopName = pname;
              })
            ];
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.fyne-demo);
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              PS1='\u@\h:\@; '
              nix run github:qbit/xin#flake-warn
              echo "Go `${pkgs.go}/bin/go version`"
            '';
            buildInputs = with pkgs; [
              git
              go
              gopls
              go-tools
              glxinfo

              glfw
              glibc
              pkg-config
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXxf86vm
              xorg.xinput
              graphviz

              go-font
            ];
          };
        });
    };
}
