{ ... }:
{
  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.in-project = true;
    };
  };
}
