{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShellNoCC {
    packages = with pkgs; [
      nodejs_21
      yarn
    ];

    shellHook = ''
      echo Node.JS $(node -v) with yarn $(yarn -v) activated!
    '';
}