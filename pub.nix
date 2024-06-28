rec {
  # this file is world readable

  # users
  rip = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0f8TJ57ydBSCKhsel9YYYcsoAsSjsj8J98bYrP+g33" ];
  deploy = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICm5b1GyKCO8dDPCEjRN/OrUq66pwKUz6MXZii78lhhX" ];

  # repos
  repo-access = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDVtpnxfQwYwnUF6zc/6dq99o804tzZUVAUnwI8aANh"
  ];

  # initrd sshd
  autoinstall = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmXMUOIB2BDTLItZ9piUg7y1SEjFZUlvj2TJbwCesUT"
  ];

  # services
  github = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" ];
  gitlab = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf" ];

  knownHosts = {
    "github.com".publicKey = toString (github);
    "gitlab.com".publicKey = toString (gitlab);
    "autoinstall".publicKey = toString (autoinstall);
  };
}
