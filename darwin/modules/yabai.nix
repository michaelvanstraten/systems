{ ... }:
{
  services.yabai.config = {
    # use bsp layout
    layout = "bsp";

    # put new windows always to the right of the current one
    window_placement = "second_child";

    # window padding
    top_padding = 12;
    bottom_padding = 12;
    left_padding = 12;
    right_padding = 12;
    window_gap = 12;

    extraConfig = ''
      # apps to not manage by default 
      yabai -m rule --add app!="^(Firefox|Skim|Firefox Nightly|Alacritty)$" manage=off 
    '';
  };
}
