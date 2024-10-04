{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./grafana-agent
    ./server
  ];
}
