{ self, nixpkgs, ... }:
{
  apps = self.lib.forAllSystems (pkgs: {
    update-jellyfin-tizen = {
      type = "app";
      program = nixpkgs.lib.getExe (
        pkgs.writeShellApplication {
          name = "update-jellyfin-tizen";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
          ];
          text = ''
            tv_ip="''${1:-192.168.178.25}"
            release_url="$(
              curl -fsSL https://api.github.com/repos/jeppevinkel/jellyfin-tizen-builds/releases/latest \
                | jq -r .html_url
            )"
            echo "Installing latest jellyfin-tizen build from $release_url"
            docker run --platform linux/x86-64 --rm ghcr.io/georift/install-jellyfin-tizen "$tv_ip" Jellyfin "$release_url"
          '';
        }
      );
    };
  });
}
