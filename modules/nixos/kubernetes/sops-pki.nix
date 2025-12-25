{ nixpkgs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    submodule
    str
    listOf
    ;

  cfg = config.services.kubernetes.sopsPki;

  mkCertConfig =
    cert: # ini
    ''
      [ req ]
      default_bits = 2048
      prompt = no
      default_md = sha256
      req_extensions = req_ext
      distinguished_name = dn

      [ dn ]
      C = <country>
      ST = <state>
      L = <city>
      O = <organization>
      OU = <organization unit>
      CN = <MASTER_IP>

      [ req_ext ]
      subjectAltName = @alt_names

      [ alt_names ]
      DNS.1 = kubernete
      DNS.2 = kubernetes.default
      DNS.3 = kubernetes.default.svc
      DNS.4 = kubernetes.default.svc.cluster
      DNS.5 = kubernetes.default.svc.cluster.local
      IP.1 = <MASTER_IP>
      IP.2 = <MASTER_CLUSTER_IP>

      [ v3_ext ]
      authorityKeyIdentifier=keyid,issuer:always
      basicConstraints=CA:FALSE
      keyUsage=keyEncipherment,dataEncipherment
      extendedKeyUsage=serverAuth,clientAuth
      subjectAltName=@alt_names
    '';

  pkgsDarwin = import nixpkgs { system = "aarch64-darwin"; };

  mkCertGenerator =
    cert: name:
    pkgsDarwin.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgsDarwin.openssl
        pkgsDarwin.sops
      ];
      text = # bash
        ''
          # Generate certificate and encrypt the key
          # shellcheck disable=SC2094
          openssl req \
            -x509 \
            -newkey ${cert.keyType} \
            -noenc \
            -CA "${cert.caCrt}" \
            -CAkey "${cert.caKey}" \
            -days 365 \
            -config ${mkCertConfig cert} \
            -extensions v3_ext \
            -out ${name}.crt \
            | sops encrypt \
                --input-type binary \
                --filename-override ${name}.key \
                ${
                  builtins.concatStringsSep " " (builtins.map (recipient: "--age \"${recipient}\"") cert.recipients)
                } \
                > ${name}.key

          echo "Certificate generated: ${name}.crt"
          echo "Encrypted key: ${name}.key"
        '';
    };
in
{
  options.services.kubernetes.sopsPki = {
    enable = lib.mkEnableOption "asda";

    encryptCertsFor = mkOption {
      description = "List of age/ssh host keys for which to encrypt the
      generated certs";
      type = listOf str;
    };

    certs = lib.mkOption {
      description = "";
      default = { };
      type = attrsOf (submodule [
        {
          options = {
            CN = mkOption {
              type = str;
            };
            hosts = mkOption {
              type = listOf str;
            };
          };
        }
      ]);
    };

  };

  config = {
    system.build.mkCertDarwin = mkCertGenerator {
      keyType = "rsa:2048";
      caCrt = "ca.crt";
      caKey = "ca.key";
      recipients = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV michael@vanstraten.de"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV michael@vanstraten.de"
      ];
    } "server";
  };
}
