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
          sha256 = "0k67x1kxnxvlj3gn4nnvmwyf8kw6i1r2l00v020aay49gzq9z8mj";
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
              pytorch
              sentencepiece
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
