{ config, ... }:
{
  networking.domain = "vanstraten.cloud";

  services.godns = {
    enable = true;
    settings = {
      provider = "Cloudflare";
      login_token_file = "$CREDENTIALS_DIRECTORY/login_token";
      domains = [
        {
          domain_name = "${config.networking.domain}";
          sub_domains = [ "${config.networking.hostName}" ];
        }
      ];
      ip_type = "IPv4";
      ip_urls = [
        "https://api.ipify.org"
        "https://ipinfo.io/ip"
      ];
      ipv6_urls = [
        "https://api6.ipify.org"
        "https://ip2location.io/ip"
        "https://v6.ipinfo.io/ip"
      ];
      interval = 300;
    };

    loadCredential = [
      "login_token:${config.sops.secrets.cloudflare-api-token.path}"
    ];
  };

  sops.secrets.cloudflare-api-token = {
    restartUnits = [ "godns.service" ];
  };
}
