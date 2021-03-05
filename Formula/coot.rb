class Coot < Formula
  include Language::Python::Virtualenv

  desc "Crystallographic Object-Oriented Toolkit"
  homepage "https://www2.mrc-lmb.cam.ac.uk/personal/pemsley/coot/"
  url "https://www2.mrc-lmb.cam.ac.uk/personal/pemsley/coot/source/releases/coot-0.9.4.1.tar.gz"
  sha256 "bd86716a1005b161e7b6a7c93902a7cc1220efa9d757e1f6bdf6532e766624e3"
  license any_of: ["GPL-3.0-only", "LGPL-3.0-only", "GPL-2.0-or-later"]

  head do
    url "https://github.com/pemsley/coot.git", branch: "gtk3"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "swig" => :build
  depends_on "wget" => :build
  depends_on xcode: :build
  depends_on "adwaita-icon-theme" # display icons
  depends_on "boost"
  depends_on "brewsci/bio/clipper4coot"
  depends_on "brewsci/bio/libccp4"
  depends_on "brewsci/bio/mmdb2"
  depends_on "brewsci/bio/raster3d"
  depends_on "brewsci/bio/ssm"
  depends_on "gd"
  depends_on "glib"
  depends_on "glm"
  depends_on "gmp"
  depends_on "goocanvas"
  depends_on "gsl"
  depends_on "gtk+3"
  depends_on "gtkglext"
  depends_on "guile@3"
  depends_on "libepoxy"
  depends_on "libidn"
  depends_on "numpy"
  depends_on "pkg-config"
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "python@3.9"
  depends_on "rdkit"
  depends_on "readline"
  # depends_on "qed"

  uses_from_macos "curl"

  resource "reference-structures" do
    url "https://www2.mrc-lmb.cam.ac.uk/personal/pemsley/coot/dependencies/reference-structures.tar.gz"
    sha256 "44db38506f0f90c097d4855ad81a82a36b49cd1e3ffe7d6ee4728b15109e281a"
  end

  resource "monomers" do
    url "https://www2.mrc-lmb.cam.ac.uk/personal/pemsley/coot/dependencies/refmac-monomer-library.tar.gz"
    sha256 "03562eec612103a48bd114cfe0d171943e88f94b84610d16d542cda138e5f36b"
  end

  def install
    ENV.cxx11
    ENV.libcxx

    if MacOS.version == :big_sur
      # Fix for current GCC on Big Sur, which does not like 11 as version value
      # (reported at https://github.com/iains/gcc-darwin-arm64/issues/31#issuecomment-750343944)
      ENV["MACOSX_DEPLOYMENT_TARGET"] = "11.0"
    else
      ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    end

    # libtool -> glibtool for macOS
    inreplace "autogen.sh", "libtool", "glibtool"
    system "./autogen.sh" if build.head?

    # Get Python location
    python_executable = Formula["python@3.9"].opt_bin/"python3"
    xy = Language::Python.major_minor_version python_executable
    ENV["PYTHONPATH"] = libexec/"lib/python#{xy}/site-packages"

    # FFTW2.1.5 location, included in the Clipper4coot Formula
    fftw2_prefix = Formula["clipper4coot"].opt_prefix/"fftw2"
    ENV.append "LDFLAGS", "-L#{Formula["clipper4coot"].opt_prefix}/fftw2/lib"
    ENV.append "CPPFLAGS", "-I#{Formula["clipper4coot"].opt_prefix}/fftw2/include"

    # set RDKit CPPFLAGS (required)
    ENV.append "CPPFLAGS", "-I#{Formula["Rdkit"].opt_include}/rdkit"

    # '--with-enhanced-ligand-tools' is not included now due to a compilation failure on lbg.cc
    args = %W[
      SHELL=/bin/bash
      --prefix=#{prefix}
      --with-boost
      --with-fftw-prefix=#{fftw2_prefix}
    ]

    # rdkit_libs is defined, but not used now.
    rdkit_libs = %W[
      "-L#{Formula["rdkit"].opt_lib}
      -lRDKitMolDraw2D
      -lRDKitForceFieldHelpers
      -lRDKitDescriptors
      -lRDKitForceField
      -lRDKitSubstructMatch
      -lRDKitOptimizer
      -lRDKitDistGeomHelpers
      -lRDKitDistGeometry
      -lRDKitAlignment
      -lRDKitEigenSolvers
      -lRDKitDepictor
      -lRDKitMolChemicalFeatures
      -lRDKitFileParsers
      -lRDKitRDGeometryLib
      -lRDKitGraphMol
      -lRDKitSmilesParse
      -lRDKitDataStructs
      -lRDKitRDGeneral
      -lboost_python39"
    ]

    rdkit_cxxflags = %W[
      "-I#{Formula["rdkit"].opt_include}/rdkit
      -DRDKIT_HAS_CAIRO_SUPPORT"
    ]

    args << "RDKIT_LIBS=#{rdkit_libs.join(" ")}"
    args << "RDKIT_CXXFLAGS=#{rdkit_cxxflags.join(" ")}"

    # coot.py is missing in src directory?
    cd "src" do
      system "wget", "https://raw.githubusercontent.com/pemsley/coot/master/src/coot.py"
    end
    system "./configure", *args
    system "make", "-j#{ENV.make_jobs}", "install"

    # install reference data
    # install data, #{pkgshare} is /path/to/share/coot
    (pkgshare/"reference-structures").install resource("reference-structures")
    (pkgshare/"lib/data/monomers").install resource("monomers")
  end

  # test block is not tested now.
  test do
    assert_match "-I#{include}", shell_output("pkg-config --cflags mmdb2")
  end
end
