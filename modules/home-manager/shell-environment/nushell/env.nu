$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend "/nix/var/nix/profiles/default/bin"
  | prepend "/run/current-system/sw/bin"
  | prepend $"/etc/profiles/per-user/($env.USER)/bin"
  | prepend $"($env.HOME)/.nix-profile/bin"
  | prepend ($env.HOME | path join .nix-profile bin)
  | prepend $"($env.HOME)/.cargo/bin"
  | uniq
)
