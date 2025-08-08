{
  system,
  pre-commit-hooks,
  ...
}:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      # Nix linting and formatting
      nil = {
        enable = true;
      };
      nixfmt-rfc-style.enable = true;
      # Disabled until pipe-operator support lands.
      # See https://github.com/oppiliappan/statix/issues/88
      statix.enable = false;

      # General formatting
      prettier = {
        enable = true;
        settings = {
          prose-wrap = "always";
        };
      };

      # Security checks
      detect-private-keys.enable = true;

      # Shell scripts
      shfmt.enable = true;
    };
  };
}
