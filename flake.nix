{
  description = "Waybar (status bar) configure by Marcus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-updates.url = "github:marcuswhybrow/flake-updates";
    networking.url = "github:marcuswhybrow/networking";
    alacritty.url = "github:marcuswhybrow/alacritty";
    logout.url = "github:marcuswhybrow/logout";
    rofi.url = "github:marcuswhybrow/rofi";
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.waybar = pkgs.symlinkJoin {
      name = "waybar";
      paths = [ 

        (pkgs.runCommand "waybar-wrapper" {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        } ''
          mkdir --parents $out/share
          ln -s ${pkgs.writeText "config" (import ./config.nix { inherit pkgs inputs; })} $out/share/config
          ln -s ${pkgs.writeText "style.css" (builtins.readFile ./style.css)} $out/share/style.css

          mkdir --parents $out/bin
          makeWrapper ${pkgs.waybar}/bin/waybar $out/bin/waybar \
            --add-flags "-c $out/share/config --style $out/share/style.css"
        '')

        pkgs.waybar 
      ];
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.waybar;
  };
}
