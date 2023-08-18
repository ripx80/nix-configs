{
  /* include as flake with: devshells.url = "/home/rip/nix-configs/modules/devshells";
     add to devShells (rust stable example):
         rust = devshells.devShells.${system}.rust-stable;
  */
  description = "dev shells";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, rust-overlay, nixpkgs }@inputs:
    let
      overlays = [ (import inputs.rust-overlay) ];
      forAllSystems =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" ];
      pkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        });
    in {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor.${system};
        in {
          home-manager =
            pkgs.mkShell { buildInputs = [ pkgs.unstable.home-manager ]; };

          go =
            pkgs.mkShell { buildInputs = with pkgs; [ go git gnumake gcc ]; };

          hugo = pkgs.mkShell { buildInputs = with pkgs; [ git hugo ]; };
          python = let
            python = pkgs.python3;
            pypackages = python.withPackages (p:
              with p;
              [
                requests
                # other python packages you want
              ]);
          in pkgs.mkShell {
            packages = [
              pypackages
              # other dependencies
            ];
          };
          pip = let
            python = pkgs.python3;
            pypackages = python.withPackages
              (p: with p; [ requests virtualenv pip setuptools ]);
          in pkgs.mkShell {
            packages = [ pypackages pkgs.readline ];
            shellHook = ''
              # Allow the use of wheels.
              SOURCE_DATE_EPOCH=$(date +%s)
            '';
          };

        } // (pkgs.lib.mapAttrs (name: rustToolchain:
          let
            rustWithExtensions = rustToolchain.override {
              extensions = [ "rust-src" "rustfmt" "clippy" ];
            };
          in pkgs.mkShell {
            name = "rust";
            packages = [ rustWithExtensions ];
            # Print backtraces on panics
            RUST_BACKTRACE = 1;
            # Certain tools like `rust-analyzer` won't work without this
            RUST_SRC_PATH =
              "${rustWithExtensions}/lib/rustlib/src/rust/library";
          }) {
            rust-nightly = pkgs.rust-bin.nightly.latest.minimal;
            rust-stable = pkgs.rust-bin.stable.latest.minimal;
            #minimum = pkgs.rust-bin.stable.0.1.0.minimal;
          }));
    };
}
