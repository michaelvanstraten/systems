{
  self,
  home-manager,
  anki-mcp,
  ...
}:
{ config, pkgs, ... }:
let
  primaryUser = "michael";
in

{
  imports = [
    home-manager.darwinModules.home-manager
    self.darwinModules.all
    self.sharedModules.all
    (self.lib.mkModule ./homebrew.nix { inherit primaryUser; })
    (self.lib.mkModule ./secrets.nix { })
    ./services/postgres.nix
  ];

  environment.systemPackages = [
    pkgs.utm
    pkgs.grandperspective
    pkgs.monitorcontrol
    pkgs.python3
    (pkgs.firefox.override {
      appDataDir = "/Users/${primaryUser}/Library/Application Support/org.nixos.firefox";
    })
    pkgs.rustup
    pkgs.lima
    pkgs.k9s
    (pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    ))
    pkgs.gh
    pkgs.xz
    pkgs.iina
    pkgs.pangolin-cli
    pkgs.ripgrep
    (pkgs.anki.withAddons [
      anki-mcp.packages.${pkgs.stdenv.system}.addon
    ])
  ];

  # nixpkgs' pyprojectVersionPatchHook fails when the version already matches
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          anki-mac-helper = pyPrev.anki-mac-helper.overridePythonAttrs (old: {
            nativeBuildInputs = builtins.filter (
              p: p != pyPrev.pyprojectVersionPatchHook
            ) old.nativeBuildInputs;
          });
        })
      ];
    })
  ];

  home-manager = {
    useUserPackages = true;
    users.${primaryUser} = self.lib.mkModule ./home.nix { };
  };

  networking = {
    computerName = "Michael’s MacBook Pro";
    hostName = "macbook-pro";
  };

  nix.autoDiscoverBuildMachines = {
    enable = true;
    sshKey = config.sops.secrets.nixremote.path;
    sshPublicKeyFile = ./nixremote.pub;
  };

  programs.fish.enable = true;

  services = {
    karabiner-elements.enable = false;
    yabai.enable = false;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    inherit primaryUser;
    stateVersion = 6;
  };

  users.users.${primaryUser} = {
    description = "Michael van Straten";
    home = "/Users/${primaryUser}";
    name = primaryUser;
    shell = pkgs.fish;
    uid = 501;
  };
}
