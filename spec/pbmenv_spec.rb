require "spec_helper"

describe Pbmenv do
  def purge_pbm_dir
    `rm -rf /usr/share/pbm`
  end

  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end

  before(:each) do
    allow(Pbmenv).to receive(:to_stdout) if ENV["DISABLE_DEBUG_LOG"]
    purge_pbm_dir
  end

  after(:each) do
    purge_pbm_dir
  end

  describe '.use' do
    context 'read donwload', :with_real_download do
      context 'latestを渡すとき' do
        subject { Pbmenv.install("0.2.1") && Pbmenv.use("0.2.1") }

        it 'currentにシムリンクが貼っている' do
          subject
          latest_version = Pbmenv.available_versions.first
          expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.2.1")
        end
      end
    end

    context 'すでにインストール済みのとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.5", "0.1.6"] }

      before(:each) do
        Pbmenv.install("0.1.5")
        Pbmenv.install("0.1.6")
      end
      after(:each) do
        Pbmenv.uninstall("0.1.5")
        Pbmenv.uninstall("0.1.6")
      end

      context 'バージョンを渡すとき' do
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

        context 'プレフィックスにvが付いているとき' do
          it 'currentにシムリンクを貼る' do
            subject
            Pbmenv.use("v0.1.6")
            expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
          end
        end
      end

      context 'latestを渡すとき' do
        subject { Pbmenv.use("latest") }

        before do
          Pbmenv.use("0.1.5")
        end

        it '最後のバージョンでcurrentにシムリンクが貼っている' do
          subject
          expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
        end
      end
    end
  end

  describe '.install, .uninstall' do
    context '0.1.6, 0.1.5の順番でインストールするとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.6", "0.1.5", "0.1.20.1"] }

      subject do
        Pbmenv.install("0.1.6")
        Pbmenv.use("0.1.6")
        Pbmenv.install("0.1.5")
      end

      it 'currentに0.1.6のシムリンクは貼らない' do
        subject
        expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.6")
      end

      # すでに別のバージョンが入っていないとuseが実行されるので、別のバージョンが入っている必要がある
      context '0.1.20.1をインストールするとき with use_option' do
        subject { Pbmenv.install("0.1.20.1", use_option: true) }

        it 'currentに0.1.20.1のシムリンクは貼る' do
          subject
          expect(File.readlink("/usr/share/pbm/current")).to eq("/usr/share/pbm/v0.1.20.1")
        end
      end

      context '0.1.6をインストールするとき', :with_decompress_procon_pbm_man do
        let(:decompress_procon_pbm_man_versions) { ["0.1.6"] }

        subject { Pbmenv.install("0.1.6") }

        it_behaves_like "correct_pbm_dir_spec" do
          let(:target_version) { "0.1.6" }
        end
      end

      context '0.1.20.1をインストールするとき', :with_decompress_procon_pbm_man do
        let(:decompress_procon_pbm_man_versions) { ["0.1.20.1"] }

        subject { Pbmenv.install("0.1.20.1", enable_pbm_cloud: true) }

        it_behaves_like "correct_pbm_dir_spec" do
          let(:target_version) { "0.1.20.1" }
        end

        it "URLの行がアンコメントアウトされていること" do
          subject
          expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  config.api_servers = \['https://pbm-cloud.herokuapp.com'\]$!)
        end
      end

      context '0.2.2をインストールするとき', :with_decompress_procon_pbm_man do
        let(:decompress_procon_pbm_man_versions) { ["0.2.2"] }

        subject { Pbmenv.install("0.2.2", enable_pbm_cloud: true) }

        it_behaves_like "correct_pbm_dir_spec" do
          let(:target_version) { "0.2.2" }
        end

        it "URLの行がアンコメントアウトされていること" do
          subject
          target_version = decompress_procon_pbm_man_versions.first
          a_pbm_path = "/usr/share/pbm/v#{target_version}"
          expect(File.exists?("#{a_pbm_path}/app.rb.erb")).to eq(false)
          # 特定行をアンコメントしていること
          expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  config.api_servers = \['https://pbm-cloud.herokuapp.com'\]$!)
        end
      end
    end

    describe 'provide "latest"' do
      it 'latest versionをインストールすること' do
        Pbmenv.install("latest")
        latest_version = Pbmenv.available_versions.first
        version_path = "/usr/share/pbm/v#{latest_version}"
        expect(Dir.exists?(version_path)).to eq(true)
        expect(File.exists?("#{version_path}/app.rb")).to eq(true)
        expect(File.exists?("#{version_path}/README.md")).to eq(true)
        expect(File.exists?("#{version_path}/setting.yml")).to eq(true)
        expect(Dir.exists?("/usr/share/pbm/shared")).to eq(true)
        expect(File.read("/usr/share/pbm/shared/device_id")).to be_a(String)
      end
    end
  end
end
