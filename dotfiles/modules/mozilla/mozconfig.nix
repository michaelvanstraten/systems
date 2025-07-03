{ config, pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [
    pkgs.sccache
  ];

  home.sessionVariables = {
    MOZCONFIG = "${config.home.homeDirectory}/.mozconfigs/ff-dbg";
  };

  home.file.".mozconfigs/ff-dbg".text = # bash
    ''
      mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-ff-dbg
      mk_add_options AUTOCLOBBER=1
      ac_add_options --enable-application=browser
      ac_add_options --enable-debug
      ac_add_options --enable-warnings-as-errors
      ac_add_options --with-ccache=sccache
    '';

  home.file.".mozconfigs/ff-rel-opt".text = # bash
    ''
      mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-ff-rel-opt
      mk_add_options AUTOCLOBBER=1
      ac_add_options --disable-debug
      ac_add_options --enable-optimize
      ac_add_options --with-ccache=sccache
    '';

  home.file.".mozconfigs/nightly-as-release".text = # bash
    ''
      mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-nightly-as-release
      ac_add_options --disable-tests
      ac_add_options --as-milestone=release
    '';

  home.file."Library/Application Support/Mozilla.sccache/config".source =
    tomlFormat.generate "sccache-config"
      {
        cache.redis.endpoint = "redis://127.0.0.1:6379";
      };
}
