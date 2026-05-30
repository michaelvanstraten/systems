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
      nil.enable = true;
      nixfmt.enable = true;

      # General formatting
      prettier = {
        enable = true;
        settings = {
          prose-wrap = "always";
        };
      };
      trim-trailing-whitespace.enable = true;

      # Security checks
      detect-private-keys.enable = true;

      # Shell scripts
      shfmt.enable = true;
    };
  };
}
