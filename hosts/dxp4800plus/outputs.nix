{
  self,
  flake-utils,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;

in
{
  nixosConfigurations.dxp4800plus = nixosSystem {
    modules = [
      (self.lib.mkModule ./configuration.nix { })
      (self.lib.mkModule ./disko.nix { })
      (self.lib.mkModule ./hardware-configuration.nix { })
    ];
  };
}
// flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { inherit system; };

    kubeadm = pkgs.kubernetes.overrideAttrs {
      WHAT = [ "cmd/kubeadm" ];
      meta.platforms = pkgs.lib.platforms.all;
    };

    generate-k8s-cas = pkgs.writeShellApplication {
      name = "generate-k8s-cas";
      runtimeInputs = with pkgs; [
        coreutils
        kubeadm
      ];
      text = ''
        set -euo pipefail

        CERT_DIR="''${1:-./k8s/pki}"
        kubeadm init phase certs ca --cert-dir "$(realpath "$CERT_DIR")"
        kubeadm init phase certs etcd-ca --cert-dir "$(realpath "$CERT_DIR")"
        kubeadm init phase certs front-proxy-ca --cert-dir "$(realpath "$CERT_DIR")"
        kubeadm init phase certs sa --cert-dir "$(realpath "$CERT_DIR")"
      '';
    };
  in
  {
    apps.generate-k8s-cas = {
      type = "app";
      program = "${generate-k8s-cas}/bin/generate-k8s-cas";
    };

    apps.kubeadm = {
      type = "app";
      program = "${kubeadm}/bin/kubeadm";
    };
  }
)
