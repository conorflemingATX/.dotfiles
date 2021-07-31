
self: super:

{
  elixir-ls = super.stdenv.mkDerivation rec {
    name = "elixir-ls-${version}";
    version = "0.6.5";
    src = super.fetchurl {
      url = "https://github.com/elixir-lsp/elixir-ls/releases/download/v${version}/elixir-ls.zip";
      sha256 = "161q1qfcgirqchh03ii6x9mmlknga4qfpxwggkqgnmdiwavhdva7";
    };
    nativeBuildInputs = [ super.unzip ];
    phases = "installPhase";
    installPhase = ''
      unzip $src -d $out
    '';
  };
}

