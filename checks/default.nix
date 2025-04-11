{
  system,
  pre-commit-hooks,
  nil_ls,
  ...
}:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      nil = {
        enable = true;
        package = nil_ls.packages.${system}.default;
      };
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
