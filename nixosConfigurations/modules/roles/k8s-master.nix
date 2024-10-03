{ lib, ... }:
{
  services.etcd.enable = true;
  # services.kubernetes = {
  #   apiserver.enable = lib.mkDefault true;
  #   scheduler.enable = lib.mkDefault true;
  #   controllerManager.enable = true;
  #   kubelet.enable = true;
  # };
}
