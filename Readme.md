# nixcfg

contains my nix profiles using flakes

## tags

you can use tags in flake nix for your configs. they are build on each other

- base: base for all systems like console layout, nix settings
- minimal: minimial nixos system with a generic hardware configuration
- dev: development environment with vscode

specify on each system

- users, only root and the deploy user are set with base
- desktop screens and driver
- monitoring

take a look at the modules.

## secrets

all secrets are protected with the personal private key under .ssh/id_ed25519. so keep it save.

there are three security layer in this config

1. encrypted on system: secrets.nix - here you defined secrets that will be encrypted in the nix store and will be decrypted on runtime via a systemd service
2. repo encrypted: meta.nix - this file will be encrypted in the git repo via git-crypt but will be readable in the nix configuration
3. public: pub.nix this file is open to the world, you can use it to defined public keys

using git-crypt and agenix.

- git-crypt: protect secrets which can be readable in global nix store on the system but encrypted in the git repo. example: wireguard server ip address and port
- agenix: protect secrets on the nix system and will be decrypted on the fly. write secret files under /run/secrets. can be used with user permissions on files.

### agenix

agenix use the secrets.nix file for all permissions and locations. Then it will be decrypt the encrypted secrets under secrets/ folder.

**keep in mind** you must check in the encrypted file in your git history. If you dont you become a file not found error from agenix when you build your system.

edit or create new secrets with exported editor env variable:

```sh
EDITOR=nano nix run github:ryantm/agenix -- -e wg0.age
```

or if you need to copy from stdin like for a passwordFile:

```sh
mkpasswd -m sha-512 password123 | tr -d '\n' | EDITOR='cp /dev/stdin' agenix -e secrets/users/user.age
```

keep in mind, when you using a passowrd file or hash and mutableUsers are enabled only on user creation the password will be set.

if you change a secret or add new members to read you must rekey all secrets.

```sh
nix run github:ryantm/agenix -- -r # rekey all secrets
```

add for each age secret a new config for example the wg private key.

```nix
age.secrets."hosts/ripbox/wg0" = {
    file = ../../secrets/hosts/ripbox/wg0.age;
    path = "/run/hosts/ripbox/wg0";
    symlink = false;
  };
```

then you can use this file with

```nix
privateKeyFile = config.age.secrets."hosts/ripbox/wg0".path;
```

here are some useful command line examples to use rage (work in the background of agenix)

```sh
# encrypt a file with the host ssh key and use identity you own key
rage -a -i id_ed25519.pub -o wgkey.age -e wg_priv

# if you want to check, decrypt the file with your priv key
rage -i id_ed25519 -d wgkey.age

# add recipiens with ssh pub keys if you want that a group can decrypt the secret
rage -a -i id_ed25519 -R /peter/id_ed25519.pub -o wgkey.age -e wg_priv

# if you dont want that a api key or a secret will be accessable in nix store you can encrypt it
echo '<apikey>' | rage -i id_ed25519 -e -a
```

### git crypt

git-crypt will encrypt the /meta.nix file on the fly. It uses a symetric key for encryption. This key is protected by agenix under secrets/symkeys/gcrypt.age.

**keep in mind** this will only be encrypted in the git repo but all secrets in this file will be readable in your configuration and so in the global nix store for all users. This will be used for secrets that must be available at compile time. example is the wg config but the secret wg private key are protected in a secret file with agenix.

to unlock the repo contents you must do this with the symetric encryption key

```sh
git-crypt unlock secrets/symkeys/gcrypt
```

### systemd env vars

if you have services they support env vars as config for secrets you can use systemd env vars.
using grafana-agent with [systemd environment vars](https://grafana.com/docs/agent/latest/configuration/#variable-substitution) add these to the config:

```nix
 age.secrets."services/monitoring/agent" = {
    file = ../../secrets/services/monitoring/agent.age;
    path = "/run/services/monitoring/agent.env";
  };
  environment.etc."grafana-agent/agent.yaml" = {
        mode = "400";
        source = ../../modules/monitoring/grafana-agent/agent.yaml;
    };

    systemd.services.grafana-agent = {
        enable = true;
        description = "grafana-agent service";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        serviceConfig = {
            Restart = "always";
            ExecStart = "${pkgs.grafana-agent}/bin/agent --config.file=/etc/grafana-agent/agent.yaml --config.expand-env";
            EnvironmentFile = config.age.secrets."services/monitoring/agent".path;
        };
    };
```

here the secret file with env vars will be encrypted via agenix and write as a normal env file to /run/services/monitoring/agent.env.
the normal agent.yaml config with env vars included as placeholder will be write to /etc/grafana-agent/agent.yml.
after all the systemd service use this file via **EnvironmentFile* option and grafana-agent will be replace the vars.

**keep in mind** set the --config.expand-env flag so that the agent will use env vars.

to keep an eye on the env vars of a systemd service get the pid of the service with ```systemctl status grafana-agent``` and lookup in /proc:

```sh
cat /proc/<pid>/environ
```

## deployment

### deploy private keyfile to host

when you build a new system localy or via vm you have no private keyfile to decrypt the defined secrets.
if you create a vm with ```sh nixos-rebuild build-vm --flake .#ripbox-vm``` you have two options to populate the host private key file.

### copy key over ssh

```sh
# start the vm with:
 /nix/store/d6s76sbhfqx7p5mznx6j8yslkybfi7n9-nixos-vm/bin/run-ripbox-vm # check your path
# you will get agenix errors because there is no key to decrypt the secrets
ssh -p 2222 localhost # check if you can connect, you will get a ssh host key error
sudo scp -P 2222 -i deploy/id_ed25519 ripbox/ssh_host_ed25519_key* root@localhost:/etc/ssh/ # copy with deployment key to ssh server as root (if root login is permittet)
reboot
```

## deploy-rs

use ssh access and nix-copy-closure to deploy profiles.
this will deploy your flake to the vm ripbox-vm as node name and the flake

```sh
deploy .#ripbox-vm
```

if you use a different ssh key you can specify this by

```sh
deploy --ssh-opts='-i ../../secrets/deploy/id_ed25519' .#ripbox-vm
```

it will use the deploy user who has sudo permissions without password to run the nix process.
if you have problems with the deployment and you want to inspect the broken system, you can disable the rollback func

```sh
deploy --ssh-opts='-i ../../secrets/deploy/id_ed25519' --magic-rollback false --auto-rollback false .#ripbox-vm
```

## nix on macos

if you want to control your macos config with nix and flakes you have two options.

### home-manager with flakes

home-manager 22.11 supports a simple flake interface:

```nix
homeConfigurations.rip = home-manager-master.lib.homeManagerConfiguration {
    pkgs = nixpkgs-unstable.legacyPackages."x86_64-darwin";
    modules = [
        ./hosts/ripmc/home.nix
    ];
};
```

then you can build from this flake

```sh
home-manager switch --flake .#rip
```

### nix-darwin with flakes

[nix-darwin](https://github.com/LnL7/nix-darwin)
[ref](https://daiderd.com/nix-darwin/manual/index.html#sec-options)

nix-darwin have a minimal set of configuration options see the ref link to inspect.
so you can not use out of the box your flakes. After you install the default config you can
use the flake with nix-darwin

```sh
cd nix-configs
nix build .#darwinConfigurations.ripmc.system
./result/sw/bin/darwin-rebuild switch --flake .#ripmc
```

maybe you have not included the flake support. Add

```sh
--extra-experimental-features nix-command --extra-experimental-features flakes
```

to the build flags.

after this you can use system darwin-rebuild with a flake configured

```sh
darwin-rebuild switch --flake .#ripmc
```

## autoinstall media

you can generate iso which will install the system via a systemd service.

```sh
mkiso # internal func to build the iso
sudo dd if=$(echo result/iso/nixos*.iso) of=/dev/sdc bs=4M # this will delete all data on /dev/sdc
```

boot the maschine with this usb stick, after a complete install you can login with the deploy user.
the default flake will be the minimal system. you can speicify the flake in your config.

## add headscale

```nix
import ../../modules/headscale.nix


# headscale noise key
age.secrets."hsnoise" = {
    file = ../../secrets/hosts/${config.networking.hostName}/hsnoise.age;
    path = "/run/secrets/hsnoise";
    owner = "headscale";
    group = "headscale";
};

# headscale private key
age.secrets."hspriv" = {
    file = ../../secrets/hosts/${config.networking.hostName}/hspriv.age;
    path = "/run/secrets/hspriv";
    owner = "headscale";
    group = "headscale";
};

ripmod.headscale = {
    enable = true;
    keyfile = config.age.secrets."hspriv".path;
    noisefile = config.age.secrets."hsnoise".path;
};

```

## add tailscale

```nix
import ../../modules/tailscale.nix

ripmod.tailscale = {
    enable = true;
    autologin = true;
    server = "http://127.0.0.1:8080";
    authkey =
    "adc875445c54dc5f74d27c1316ec1533d095155c9a67dfb8"; # only one-shot keys
};
```
