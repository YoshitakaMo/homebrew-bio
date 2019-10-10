class Xmatchview < Formula
  # cite L_Warren_2018: "https://doi.org/10.21105/joss.00497"
  desc "Smith-waterman alignment visualization"
  homepage "https://github.com/bcgsc/xmatchview"
  url "https://github.com/bcgsc/xmatchview/archive/v1.2.0.tar.gz"
  sha256 "17723ba8d6162c2b57f9c63f1f93fcc878963eb00097a12a575c8b3b3c9ef1bf"
  head "https://github.com/bcgsc/xmatchview.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles-bio"
    cellar :any
    sha256 "8c7c07606ed33a2f6b435de93510566b01b737987a8c97f373735350c8a391a2" => :sierra
    sha256 "a5a8927f3ba541355ccb4fea94e2f639651e55bff2c2641cc04ffb8594774b5f" => :x86_64_linux
  end

  depends_on "jpeg"
  depends_on "python@2"
  depends_on "zlib" unless OS.mac?

  def install
    ENV.prepend_path "PATH", libexec/"bin"
    xy = Language::Python.major_minor_version "python2"
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "pip", "install", "--prefix=#{libexec}", "pillow", "--no-binary=pillow"
    inreplace "xmatchview.py", "#!/usr/bin/python", "#!/usr/bin/env python"
    inreplace "xmatchview-conifer.py", "#!/usr/bin/python", "#!/usr/bin/env python"
    prefix.install Dir["xmatchview*py"]
    prefix.env_script_all_files libexec/"bin", :PYTHONPATH => Dir[libexec/"lib/python*/site-packages"].first
    bin.install_symlink "../xmatchview.py", "../xmatchview-conifer.py"
    chmod 0555, Dir[prefix/"xmatchview*py"]
    prefix.install "test"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/xmatchview.py", 1)
    assert_match "Usage", shell_output("#{bin}/xmatchview-conifer.py", 1)
  end
end
