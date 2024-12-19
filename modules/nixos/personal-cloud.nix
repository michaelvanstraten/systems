{ config, ... }:
{
  networking.domain = "vanstraten.cloud";

  services.godns = {
    enable = true;
    configFile = config.sops.templates."godns-config.yaml".path;
    additionalRestartTriggers = [
      config.sops.templates."godns-config.yaml".content
    ];
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
        - https://ip2location.io/ip
        - https://v6.ipinfo.io/ip
      ip_type: IPv6
      interval: 300
    '';
}
