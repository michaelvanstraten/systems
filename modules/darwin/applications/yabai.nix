{
  services.yabai = {
    enable = true;
    extraConfig = # bash
      ''
        # use bsp layout
        yabai -m config layout bsp

        # put new windows always to the right of the current one
        yabai -m config window_placement second_child

        # window padding
        yabai -m config top_padding     12
        yabai -m config bottom_padding  12
        yabai -m config left_padding    12
        yabai -m config right_padding   12
        yabai -m config window_gap      12

        # apps to not manage by default
        yabai -m rule --add app!="^(Firefox|Skim|Firefox Nightly|Alacritty)$" manage=off
      '';
  };
}
