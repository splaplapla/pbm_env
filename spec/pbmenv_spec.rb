require "spec_helper"

describe Pbmenv do
  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end
  before(:all) do
    system "tar zxvf ./spec/files/procon_bypass_man-0.1.6.tar.gz"
  end
  after(:all) do
    system "rm -rf procon_bypass_man-0.1.6"
  end

  describe 'install, uninstall' do
    before do
      allow(Pbmenv).to receive(:download_src)
    end
    subject { Pbmenv.install("0.1.6") }
    it 'currentにシムリンクが貼っている' do
      subject
      expect(FileTest.symlink?("/usr/share/pbm/current")).to eq(true)
    end
    it '/usr/share/pbm/0.1.6/ にファイルを作成すること' do
      subject
      expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(true)
    end
    it '' do
      subject
      expect { Pbmenv.install("0.1.6") }.not_to raise_error
    end
    it 'uninstallできること' do
      subject
      Pbmenv.uninstall("0.1.6")
      expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(false)
    end
  end
end
