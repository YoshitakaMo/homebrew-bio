class Seqkit < Formula
  # cite Shen_2016: "https://doi.org/10.1371/journal.pone.0163962"
  desc "Ultrafast FASTA/Q file manipulation"
  homepage "https://bioinf.shenwei.me/seqkit/"
  # We use binaries to avoid compiling Go code
  if OS.mac?
    url "https://github.com/shenwei356/seqkit/releases/download/v0.13.1/seqkit_darwin_amd64.tar.gz"
    sha256 "66e02814bf53298684aab03b62c5843ca18a73c5981f63a499797c9ab0ea614f"
  else
    url "https://github.com/shenwei356/seqkit/releases/download/v0.13.1/seqkit_linux_amd64.tar.gz"
    sha256 "53d4b06240be2292251b9304d405a22c9f32cc6fa2cd59d2bb6cc35bd73f57f7"
  end
  version "0.13.1"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles-bio"
    cellar :any_skip_relocation
    sha256 "7a5805209ae2a70e39efa71125ac23215a6f5a56f240213483071a0d31adaa93" => :catalina
    sha256 "6cd3a52182fef2036cabb50dee045e258d1b5b392ff689c1b257315b4e82223b" => :x86_64_linux
  end

  def install
    bin.install "seqkit"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/seqkit version")
  end
end
