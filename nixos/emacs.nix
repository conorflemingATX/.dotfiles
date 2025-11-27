{ pkgs }:
with pkgs;
emacsWithPackagesFromUsePackage {
  config = /home/conor/.config/emacs/init.el;
  package = emacs-git;
}
