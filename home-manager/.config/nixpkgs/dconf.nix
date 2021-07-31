# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {
    "org/gnome/control-center" = {
      last-panel = "wifi";
    };

    "org/gnome/desktop/input-sources" = {
      current = "uint32 0";
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "eurosign:e" ];
    };

    "org/gnome/desktop/interface" = {
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      text-scaling-factor = 1.4;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "gnome-power-panel" "spotify" ];
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/spotify" = {
      application-id = "spotify.desktop";
    };

    "org/gnome/desktop/privacy" = {
      report-technical-problems = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 3;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
      network-monitor-gio-name = "";
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 250;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = false;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      workspaces-only-on-primary = false;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      maximized = false;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-last-coordinates = mkTuple [ 29.683398560115194 (-95.7245) ];
    };

    "org/gnome/settings-daemon/plugins/xsettings" = {
      antialiasing = "grayscale";
      hinting = "slight";
    };

    "org/gnome/shell" = {
      enabled-extensions = "@as []";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/system/location" = {
      enabled = true;
    };

    "org/gnome/terminal/legacy" = {
      theme-variant = "dark";
    };

    "org/gnome/terminal/legacy/profiles:" = {
      default = "ed87f63d-9d01-4a71-8c5b-6f0d674b7b49";
      list = [ "ed87f63d-9d01-4a71-8c5b-6f0d674b7b49" ];
    };

    "org/gnome/terminal/legacy/profiles:/:ed87f63d-9d01-4a71-8c5b-6f0d674b7b49" = {
      background-color = "#282A36";
      bold-color = "#6E46A4";
      bold-color-same-as-fg = false;
      bold-is-bright = true;
      cursor-colors-set = false;
      font = "FiraCode Nerd Font Mono 11";
      foreground-color = "#F8F8F2";
      highlight-colors-set = false;
      palette = [ "#262626" "#E356A7" "#42E66C" "#E4F34A" "#9B6BDF" "#E64747" "#75D7EC" "#EEE8D5" "#7A7A7A" "#FF79C6" "#50FA7B" "#F1FA8C" "#BD93F9" "#FF5555" "#8BE9FD" "#FDF6E3" ];
      use-system-font = false;
      use-theme-colors = false;
      visible-name = "Default";
    };

    "org/gtk/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.8980392156862745 0.8980392156862745 ]) (mkTuple [ 0.9803921568627451 0.9215686274509803 ]) (mkTuple [ 0.9333333333333333 0.9098039215686274 ]) (mkTuple [ 0.9921568627450981 0.9647058823529412 ]) (mkTuple [ 0.0 0.16862745098039217 ]) (mkTuple [ 0.0 0.0 ]) (mkTuple [ 0.0 0.0 ]) ];
      selected-color = mkTuple [ true 0.9921568627450981 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 203;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 0 39 ];
      window-size = mkTuple [ 1920 991 ];
    };

  };
}
