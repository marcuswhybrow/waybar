{ pkgs, mwpkgs, ... }: let 
  icon = text: ''<span color="#fff" font_family="Font Awesome 6 Free">${text}</span>'';
  flake-updates = "${mwpkgs.flake-updates}/bin/flake-updates";
  networking = "${mwpkgs.networking}/bin/networking";
  alacritty = "${mwpkgs.alacritty}/bin/alacritty";
  logout = "${mwpkgs.logout}/bin/logout";
  rofi = "${mwpkgs.rofi}/bin/rofi";
  htop = "${pkgs.htop}/bin/htop";
  open = "${pkgs.xdg-utils}/bin/xdg-open";
  qdirstat = "${pkgs.qdirstat}/bin/qdirstat";
in builtins.toJSON {
  layer = "top";
  position = "top";
  ipc = false;
  margin = "10 20 -10 20";
  height = null;
  width = null;

  modules-left = [
    "custom/apps"
    "custom/wifi-alarm"
    "network"
    "cpu"
    "memory"
    "temperature"
    "disk"
    "battery"
  ];

  modules-center = [
    "hyprland/workspaces"
    "tray"
  ];

  modules-right = [
    # "bluetooth"
    "custom/updates"
    "clock#date"
    "custom/logout"
  ];

  tray = {
    icon-size = 21;
    spacing = 10;
  };

  # https://github.com/Alexays/Waybar/wiki/Module:-Network
  network = {
    interval = 1;
    on-click = ''${networking}'';

    format = "${icon ""} Disabled";
    tooltip = "Networking disabled";

    format-wifi = "${icon ""} {signalStrength:02}%";
    tooltip-format-wifi = "{essid} {signalStrength}% {ipaddr}";

    format-ethernet = "${icon ""} {ipaddr}";
    tooltip-format-ethernet = "Ethernet {ipaddr}";

    format-disconnected = "${icon ""} Disconnected";
    tooltip-format-disconnected = "Disconnected";
  };

  "custom/wifi-alarm" = {
    # This detmines if the WiFi radio is on
    # Ref: https://unix.stackexchange.com/questions/260235/command-to-detect-if-internet-connection-is-wired-or-wireless
    exec = ''
      ip route get 8.8.8.8 2> /dev/null | \
      grep -Po 'dev \K\w+' | \
       grep -qFf - /proc/net/wireless \
      || [[ $(nmcli radio wifi) == enabled ]] \
      && echo '⚠️'
    '';
    interval = 1;
    on-click = "${networking}";
  };

  "custom/updates" = {
    exec = "${flake-updates} --flake ~/Repositories/nixos --output ' %s'";
    on-click = "${alacritty} --working-directory ~/Repositories/nixos";
    interval = 1;
  };

  "custom/apps" = {
    format = "Apps";
    on-click = ''${rofi} -show drun -i -drun-display-format {name} -theme-str 'entry { placeholder: "Launch"; }' '';
    tooltip = false;
  };

  "custom/logout" = {
    format = "";
    on-click = "${logout}";
    tooltip = false;
  };

  cpu = {
    format = "${icon ""} {usage:02}%";
    interval = 1;
    states = {
      warning = 70;
      critical = 90;
    };
    on-click = "${alacritty} --command ${htop} --sort-key=PERCENT_CPU";
  };

  memory = {
    interval = 1;
    format = ''${icon ""} {percentage:02}%'';
    tooltip-format = "{used:0.1f}/{total:0.1f}GB RAM";
    states = {
      warning = 70;
      critical = 90;
    };
    on-click = "${alacritty} --command ${htop} --sort-key=PERCENT_MEM";
  };

  temperature = {
    interval = 1;
    format = "${icon ""} {temperatureC:02}°C";
    tooltip-format = "{temperatureC}°C";
    critical-threshold = 88;
  };

  disk = {
    interval = 3;
    format = "${icon ""} {free}";
    tooltip-format = "{used} of {total} SSD";
    on-click = "${qdirstat} ~";
  };

  # https://github.com/Alexays/Waybar/wiki/Module:-Battery
  battery = {
    interval = 1;
    format = "${icon ""} {capacity:02}%";
    tooltip-format = "{timeTo}";

    format-charging = "${icon ""} {capacity:02}%";
    tooltip-format-charging = "{timeTo}";

    format-discharging = "${icon ""} {capacity:02}%";
    tooltip-format-discharging = "{timeTo}";

    states = {
      good = 95;
      warning = 20;
      critical = 10;
    };
  };

  "clock#date" = {
    tooltip = false;
    format = "{:%a %d %b %H:%M}"; # https://fmt.dev/dev/syntax.html#chrono-specs
    on-click = "${open} https://calendar.proton.me/u/1";
  };
}
