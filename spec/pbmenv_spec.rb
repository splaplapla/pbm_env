require "spec_helper"

describe Pbmenv do
  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end

  before(:each) do
    system "tar zxvf ./spec/files/procon_bypass_man-0.1.6.tar.gz > /dev/null"
  end

  after(:each) do
    system "rm -rf procon_bypass_man-0.1.6"
  end

  describe '.use' do
    context 'すでにインストール済みのとき' do
      before(:each) { Pbmenv.install("0.1.6") }
      after(:each) { Pbmenv.uninstall("0.1.6") }

      subject { Pbmenv.use("0.1.6") }

      it 'currentにシムリンクが貼っている' do
        subject
        expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
      end

      context 'インストールしていないバージョンをuseするとき' do
        it 'currentのシムリンクを更新しない' do
          subject
          Pbmenv.use("0.1.7")
          expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
        end
      end
    end
  end

  describe '.install, .uninstall' do
    before { allow(Pbmenv).to receive(:download_src) }
    after(:each) { Pbmenv.uninstall("0.1.6") }

    subject { Pbmenv.install("0.1.6") }

    context 'インストール済みのバージョンがあるとき' do
      it 'もう一度installしてもエラーにならない' do
        subject
        expect { Pbmenv.install("0.1.6") }.not_to raise_error
      end
    end

    it 'currentにシムリンクが貼っていない' do
      subject
      expect(FileTest.symlink?("/usr/share/pbm/current")).to eq(false)
    end

    it '/usr/share/pbm/v0.1.6/ にファイルを作成すること' do
      subject
      expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(true)
    end

    it 'sheardディレクトリを作成すること' do
      subject
      expect(Dir.exists?("/usr/share/pbm/shared")).to eq(true)
    end

    it '/usr/share/pbm/v0.1.6/device_idを作成すること' do
      subject
      expect(File.symlink?("/usr/share/pbm/v0.1.6/device_id")).to eq(true)
    end

    it '/usr/share/pbm/shared/device_idを作成すること' do
      subject
      expect(File.exists?("/usr/share/pbm/shared/device_id")).to eq(true)
    end

    it 'uninstallできること' do
      subject
      Pbmenv.uninstall("0.1.6")
      expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(false)
    end

    describe 'provide "latest"' do
      it do
        Pbmenv.install("latest")
        latest_version = Pbmenv.available_versions.first
        expect(Dir.exists?("/usr/share/pbm/v#{latest_version}")).to eq(true)
      end
    end
  end
end
