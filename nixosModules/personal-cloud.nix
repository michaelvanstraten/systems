{ config, ... }:
{
  networking.domain = "vanstraten.cloud";

  services.godns = {
    enable = true;
    configPath = config.sops.templates."godns-config.yaml".path;
  };

  sops.templates."godns-config.yaml".content = # yaml
    ''
      provider: Cloudflare
      login_token: "${config.sops.placeholder.cloudflare-api-token}"
      domains:
        - domain_name: "${config.networking.domain}"
          sub_domains:
            - "${config.networking.hostName}"
      ipv6_urls:
        - https://api6.ipify.org
        - https://api-ipv6.ip.sb/ip
        - https://ip2location.io/ip
        - https://v6.ipinfo.io/ip
      ip_type: IPv6
      interval: 300
    '';
}
