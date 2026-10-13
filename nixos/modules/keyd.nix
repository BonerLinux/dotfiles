{
  # GLFW-based apps (e.g. Minecraft) read raw evdev scancodes and ignore
  # compositor-level XKB remaps like Hyprland's `kb_options = "caps:swapescape"`.
  # keyd remaps at the kernel evdev layer instead, so the swap is already in
  # effect before Wayland/XKB/GLFW ever see the keypress.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "esc";
        esc = "capslock";
      };
    };
  };
}
