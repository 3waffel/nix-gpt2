{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        gpt2-medium-chinese = pkgs.fetchgit {
          url = "https://huggingface.co/mymusise/gpt2-medium-chinese";
          branchName = "main";
          rev = "97a07265c8a4724f381968060abb979d759ce628";
          sha256 = "mj4dTyggUsr9YFSfToKaLVOFAv+D5HdgjUgxdaoo6Us=";
          fetchLFS = true;
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          src = gpt2-medium-chinese;
          name = "gpt2-medium-chinese";
          installPhase = ''
            cp -r $src $out
          '';
        };

        devShells.default = let
          pythonWithPackages = pkgs.python39.withPackages (p:
            with p; [
              tensorflow
              keras
              transformers
            ]);
        in
          pkgs.mkShell {
            buildInputs = [
              pythonWithPackages
              pkgs.pyright
              self.packages.${system}.default
            ];
            shellHook = ''
              export PYTHONPATH=${pythonWithPackages}/${pythonWithPackages.sitePackages}
              export MODELPATH=${self.packages.${system}.default}
            '';
          };
      }
    );
}
