{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    talhelper.url = "github:budimanjojo/talhelper";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    talhelper,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        talhelperPkg = talhelper.packages.${system}.default;
      in {
        devShell = pkgs.mkShell {
          name = "k8s";

          shellHook = ''
            export ROOT_DIR=$(pwd)
            export SOPS_AGE_KEY_FILE=$ROOT_DIR/age.key
            export KUBECONFIG=$ROOT_DIR/kubeconfig
            export TALOSCONFIG=$ROOT_DIR/talos/clusterconfig/talosconfig
          '';

          buildInputs = with pkgs; [
            bash
            k9s
            fluxcd
            go-task
            talosctl
            kustomize
            kubectl
            kubeconform
            kubernetes-helm
            sops
            cilium-cli
            helmfile
            jq
            yq
            talosctl
            cloudflared
            age
            cue
            makejinja
            talhelperPkg
          ];
        };
      }
    );
}
