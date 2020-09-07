{ stdenv
, fetchzip
, jre
, makeWrapper
, makeDesktopItem
, iconConvTools
}:

stdenv.mkDerivation rec {
  pname = "protege";
  version = "5.5.0";

  src = fetchzip {
    url = "https://github.com/protegeproject/protege-distribution/releases/download/v${version}/Protege-${version}-platform-independent.zip";
    sha256 = "1v82ph1pqvnc1qynhiapzw0jwm9rphsb580lc96zwsvhrr0wd690";
  };

  nativeBuildInputs = [ makeWrapper iconConvTools ];

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    desktopName = "Protege";
    genericName = meta.description;
    comment = meta.description;
    categories = "Development;";
    icon = pname;
    extraEntries = ''
      StartupWMClass=${pname}
    '';
  };

  # makeWrapper flags adapted from protege's run.sh script (see extracted sources)
  installPhase = ''
    mkdir -p $out/src
    mv * $out/src

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --run "cd $out/src" \
      --add-flags "-Xmx500M -Xms200M" \
      --add-flags "-Xss16M" \
      --add-flags "-Dlogback.configurationFile=conf/logback.xml" \
      --add-flags "-DentityExpansionLimit=100000000" \
      --add-flags "-Dfile.encoding=UTF-8" \
      --add-flags "-XX:CompileCommand=exclude,javax/swing/text/GlyphView,getBreakSpot" \
      --add-flags "-classpath bundles/guava.jar:bundles/logback-classic.jar:bundles/logback-core.jar:bundles/slf4j-api.jar:bin/org.apache.felix.main.jar:bin/maven-artifact.jar:bin/protege-launcher.jar" \
      --add-flags "org.protege.osgi.framework.Launcher"

    mkdir -p $out/share
    ${desktopItem.buildCommand}
    icoFileToHiColorTheme $out/src/app/Protege.ico $pname $out
  '';

  meta = {
    description = "Ontology editor and framework for building intelligent systems";
    license = stdenv.lib.licenses.bsd2;
    platforms = stdenv.lib.platforms.unix;
    homepage = "https://protege.stanford.edu";
    downloadPage = "https://github.com/protegeproject/protege-distribution/releases";
    changelog = "https://github.com/protegeproject/protege-distribution/releases/tag/v${version}";
  };
}
