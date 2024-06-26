{
  description = "Waybar (status bar) configure by Marcus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mwpkgs = {
      url = "github:marcuswhybrow/mwpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    mwpkgs = inputs.mwpkgs.packages.x86_64-linux;
    waybar = pkgs.waybar;

    configText = import ./config.nix { inherit pkgs mwpkgs; };
    config = pkgs.writeText "config" configText;

    styleText = builtins.readFile ./style.css;
    style = pkgs.writeText "style.css" styleText;

    wrapper = pkgs.runCommand "waybar-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir --parents $out/share
      ln -s ${config} $out/share/config
      ln -s ${style} $out/share/style.css

      mkdir --parents $out/bin
      makeWrapper ${waybar}/bin/waybar $out/bin/waybar \
        --add-flags "-c $out/share/config --style $out/share/style.css"
    '';
  in {
    packages.x86_64-linux.waybar = pkgs.symlinkJoin {
      name = "waybar";
      paths = [ wrapper waybar ]; # first ./bin/waybar has precedence
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.waybar;
  };
}
