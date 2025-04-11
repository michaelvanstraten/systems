{ system, pre-commit-hooks, ... }:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      nil.enable = true;
      nixfmt-rfc-style.enable = true;
      prettier = {
        enable = true;
        settings = {
          prose-wrap = "always";
        };
      };
    };
  };
}
