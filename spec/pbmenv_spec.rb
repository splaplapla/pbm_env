require "spec_helper"

describe Pbmenv do
  def purge_pbm_dir
    system "rm -rf /usr/share/pbm"
  end

  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end

  before(:each) do
    system "tar zxvf ./spec/files/procon_bypass_man-0.1.5.tar.gz > /dev/null"
    system "tar zxvf ./spec/files/procon_bypass_man-0.1.6.tar.gz > /dev/null"
  end

  after(:each) do
    system "rm -rf procon_bypass_man-0.1.6"
    system "rm -rf procon_bypass_man-0.1.5"
    purge_pbm_dir
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
    context 'stub download 0.2.2', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.2.2"] }

      describe '.install' do
        subject { Pbmenv.install("0.2.2") }

        it 'app.rb.erbを削除していること' do
          subject
          target_version = decompress_procon_pbm_man_versions.first
          a_pbm_path = "/usr/share/pbm/v#{target_version}"
          expect(Dir.exists?(a_pbm_path)).to eq(true)
          expect(File.exists?("#{a_pbm_path}/app.rb.erb")).to eq(false)
          expect(File.exists?("#{a_pbm_path}/app.rb")).to eq(true)
          expect(File.exists?("#{a_pbm_path}/README.md")).to eq(true)
          expect(File.exists?("#{a_pbm_path}/setting.yml")).to eq(true)

          # 特定行をアンコメントしていること
          expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  config.api_servers = \['https://pbm-cloud.herokuapp.com'\]$!)
        end

        it '解凍したファイルを削除していること' do
          subject
          target_version = decompress_procon_pbm_man_versions.first
          expect(Dir.exists?("procon_bypass_man-#{target_version}")).to eq(false)
        end

        it 'uninstallしたらディレクトリを消す' do
          subject
          target_version = decompress_procon_pbm_man_versions.first
          a_pbm_path = "/usr/share/pbm/v#{target_version}"
          expect { Pbmenv.uninstall(target_version) }.to change { Dir.exists?(a_pbm_path) }.from(true).to(false)
        end
      end
    end

    context 'stub download with 0.1.6, 0.1.5' do
      before { allow(Pbmenv).to receive(:download_src) }

      context 'インストール済みのバージョンがあるとき' do
        it 'もう一度installしてもエラーにならない' do
          Pbmenv.install("0.1.6")
          expect { Pbmenv.install("0.1.6") }.not_to raise_error
        end
      end

      context '0.1.6, 0.1.5の順番でインストールするとき' do
        before do
          Pbmenv.install("0.1.6")
          Pbmenv.use("0.1.6")
          Pbmenv.install("0.1.5")
        end

        it 'currentに0.1.6のシムリンクは貼らない' do
          expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
        end
      end

      context '0.1.6をインストールするとき' do
        subject { Pbmenv.install("0.1.6") }

        it '/usr/share/pbm/v0.1.6/ にファイルを作成すること' do
          subject
          expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(true)
          expect(File.exists?("/usr/share/pbm/v0.1.6/app.rb")).to eq(true)
        end

        it 'sheardディレクトリを作成すること' do
          subject
          expect(Dir.exists?("/usr/share/pbm/shared")).to eq(true)
        end

        it '/usr/share/pbm/v0.1.6/device_idを作成すること' do
          subject
          expect(File.readlink("/usr/share/pbm/v0.1.6/device_id")).to eq("/usr/share/pbm/shared/device_id")
        end

        it '/usr/share/pbm/shared/device_idを作成すること' do
          subject
          expect(File.read("/usr/share/pbm/shared/device_id")).to be_a(String)
        end

        it 'uninstallできること' do
          subject
          Pbmenv.uninstall("0.1.6")
          expect(Dir.exists?("/usr/share/pbm/v0.1.6")).to eq(false)
        end
      end
    end

    context 'real download' do
      describe 'provide "latest"' do
        it do
          Pbmenv.install("latest")
          latest_version = Pbmenv.available_versions.first
          version_path = "/usr/share/pbm/v#{latest_version}"
          expect(Dir.exists?(version_path)).to eq(true)
          expect(File.exists?("#{version_path}/app.rb")).to eq(true)
          expect(File.exists?("#{version_path}/README.md")).to eq(true)
          expect(File.exists?("#{version_path}/setting.yml")).to eq(true)
        end
      end
    end
  end
end
