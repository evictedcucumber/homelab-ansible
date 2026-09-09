{
  description = "Environment for my Ansible Homelab Configuration.";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      config.allowUnfree = true;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "homelab-ansible";
      packages = with pkgs; [
        ansible
        ansible-language-server
        ansible-lint
        lefthook
        python3
        yamlfix
      ];
    };
  };
}
