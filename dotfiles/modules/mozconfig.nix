{ config, pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [
    pkgs.sccache
  ];

  home.sessionVariables = {
    MOZCONFIG = "${config.home.homeDirectory}/.mozconfigs/mozconfig-ff-dbg";
  };

  home.file.".mozconfigs/mozconfig-ff-dbg".text = # bash
    ''
      mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-ff-dbg
      mk_add_options AUTOCLOBBER=1
      ac_add_options --enable-application=browser
      ac_add_options --enable-debug
      ac_add_options --enable-warnings-as-errors
      ac_add_options --with-ccache=sccache
    '';

  home.file."Library/Application Support/Mozilla.sccache/config".source =
    tomlFormat.generate "sccache-config"
      {
        cache.redis.endpoint = "redis://127.0.0.1:6379";
      };
}
