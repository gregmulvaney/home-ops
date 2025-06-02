{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  output = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          name = "k8s";

          buildInputs = with pkgs; [
            k9s
            fluxcd
            go-task
            talosctl
            kustomize
            kubectl
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
          ];

          KUBECONFIG = "./kubeconfig";
          SOPS_AGE_KEY_FILE = "age.key";
          TALOSCONFIG = "./talos/clusterconfig/talosconfig";
        };
      }
    );
}
