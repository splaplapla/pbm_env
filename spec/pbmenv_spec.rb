require "spec_helper"

describe Pbmenv do
  def purge_pbm_dir
    `rm -rf /usr/share/pbm`
  end

  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end

  before(:each) do
    allow(Pbmenv::Helper).to receive(:to_stdout) if ENV["DISABLE_DEBUG_LOG"]
    allow(Pbmenv).to receive(:available_versions) {
      ["0.3.7", "0.3.6", "0.3.5", "0.3.4", "0.3.3.1", "0.3.3", "0.3.2", "0.3.1", "0.3.0", "0.2.3", "0.2.2", "0.2.1", "0.2.0", "0.1.23", "0.1.22", "0.1.21", "0.1.20.2", "0.1.20.1", "0.1.20", "0.1.19.1", "0.1.19", "0.1.18", "0.1.17", "0.1.16.1", "0.1.16", "0.1.15", "0.1.14", "0.1.13", "0.1.12", "0.1.11"]
    }
    purge_pbm_dir
  end

  describe '.available_versions'do
    subject { Pbmenv.available_versions }

    it 'エラーが起きないこと' do
      # rate limitに引っかからないようにここだけは実際にapi callする
      allow(Pbmenv).to receive(:available_versions).and_call_original
      subject
    end
  end

  describe '.installed_versions' do
    subject { described_class.installed_versions }

    context 'バージョンがないとき' do
      it do
        expect(subject).to eq([])
      end
    end

    context 'バージョンが1個だけあるとき' do
      context 'currentディレクトリがない' do
        before do
          FakeVersionDirFactory.create('0.1.0')
        end

        it do
          expect(subject.size).to eq(1)
          version_object = subject.last
          expect(version_object).to have_attributes(latest_version?: true, current_version?: false, version_name: '0.1.0')
        end
      end

      context 'currentディレクトリがある' do
        before do
          FakeVersionDirFactory.create('0.1.0', symlink_to_current: true)
        end

        it do
          expect(subject.size).to eq(1)
          version_object = subject.last
          expect(version_object).to have_attributes(latest_version?: true, current_version?: true, version_name: '0.1.0')
        end
      end
    end

    context 'バージョンがn個あるとき' do
      context 'currentディレクトリがない' do
        before do
          FakeVersionDirFactory.create('0.1.0')
          FakeVersionDirFactory.create('0.2.0')
          FakeVersionDirFactory.create('0.3.0')
        end

        it do
          expect(subject.size).to eq(3)
          expect(subject[0]).to have_attributes(latest_version?: false, current_version?: false, version_name: '0.1.0')
          expect(subject[1]).to have_attributes(latest_version?: false, current_version?: false, version_name: '0.2.0')
          expect(subject[2]).to have_attributes(latest_version?: true, current_version?: false, version_name: '0.3.0')
        end
      end

      context 'currentディレクトリがある' do
        before do
          FakeVersionDirFactory.create('0.1.0')
          FakeVersionDirFactory.create('0.2.0', symlink_to_current: true)
          FakeVersionDirFactory.create('0.3.0')
        end

        it do
          expect(subject.size).to eq(3)
          expect(subject[0]).to have_attributes(latest_version?: false, current_version?: false, version_name: '0.1.0')
          expect(subject[1]).to have_attributes(latest_version?: false, current_version?: true, version_name: '0.2.0')
          expect(subject[2]).to have_attributes(latest_version?: true, current_version?: false, version_name: '0.3.0')
        end
      end
    end
  end

  describe 'integration' do
    subject do
      Pbmenv.install(target_version)
      Pbmenv.use(target_version)
    end

    context '0.2.1を渡すとき' do
      let(:target_version) { "0.2.1" }

      it 'currentにシムリンクが貼っている' do
        expect(subject).to eq(true)
        latest_version = Pbmenv.available_versions.detect { |x| x == target_version }
        version_path = "/usr/share/pbm/v#{latest_version}"
        expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v#{target_version}")
        expect(Dir.exist?(version_path)).to eq(true)
        expect(File.exist?("#{version_path}/app.rb")).to eq(true)
        expect(File.exist?("#{version_path}/README.md")).to eq(true)
        expect(File.exist?("#{version_path}/setting.yml")).to eq(true)
        expect(Dir.exist?("/usr/share/pbm/shared")).to eq(true)
        expect(File.read("/usr/share/pbm/shared/device_id")).to be_a(String)
      end
    end

    context '存在しないバージョンを渡すとき' do
      let(:target_version) { "999.999.999" }

      it do
        expect(subject).to eq(false)
      end
    end

    context 'latestを渡すとき' do
      let(:target_version) { "latest" }

      it 'currentにシムリンクが貼っている' do
        subject
        latest_version = Pbmenv.available_versions.first
        version_path = "/usr/share/pbm/v#{latest_version}"
        expect(Pbmenv.current_directory.readlink).to match(%r!/usr/share/pbm/v[\d.]+!)
        expect(Dir.exist?(version_path)).to eq(true)
        expect(File.exist?("#{version_path}/app.rb")).to eq(true)
        expect(File.exist?("#{version_path}/README.md")).to eq(true)
        expect(File.exist?("#{version_path}/setting.yml")).to eq(true)
        expect(Dir.exist?("/usr/share/pbm/shared")).to eq(true)
        expect(File.read("/usr/share/pbm/shared/device_id")).to be_a(String)
      end
    end
  end

  describe '.use' do
    context 'すでにインストール済みのとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.5", "0.1.6"] }

      before(:each) do
        Pbmenv.install("0.1.5")
        Pbmenv.install("0.1.6")
      end

      context 'バージョンを渡すとき' do
        subject { Pbmenv.use("0.1.6") }

        it 'currentにシムリンクが貼っている' do
          subject
          expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.6")
        end

        context 'インストールしていないバージョンをuseするとき' do
          it 'currentのシムリンクを更新しない' do
            subject
            Pbmenv.use("0.1.7")
            expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.6")
          end
        end

        context 'プレフィックスにvが付いているとき' do
          it 'currentにシムリンクを貼る' do
            subject
            Pbmenv.use("v0.1.6")
            expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.6")
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
          expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.6")
        end
      end
    end
  end

  describe '.install, .uninstall' do
    context 'プレフィックスにvが付いているとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.5"] }
      let(:target_version) { decompress_procon_pbm_man_versions.first }

      subject { Pbmenv.install("v0.1.5") }

      include_examples "correct_pbm_dir_spec"
    end

    context '0.1.6, 0.1.5の順番でインストールするとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.6", "0.1.5", "0.1.20.1"] }

      subject do
        Pbmenv.install("0.1.6")
        Pbmenv.use("0.1.6")
        Pbmenv.install("0.1.5")
      end

      it 'currentに0.1.6のシムリンクは貼らない' do
        subject
        expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.6")
      end

      # すでに別のバージョンが入っていないとuseが実行されるので、別のバージョンが入っている必要がある
      context '0.1.20.1をインストールするとき with use_option' do
        subject { Pbmenv.install("0.1.20.1", use_option: true) }

        it 'currentに0.1.20.1のシムリンクは貼る' do
          subject
          expect(Pbmenv.current_directory.readlink).to eq("/usr/share/pbm/v0.1.20.1")
        end
      end
    end

    context '0.1.6をインストールするとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.6"] }
      let(:target_version) { decompress_procon_pbm_man_versions.first }

      subject { Pbmenv.install(target_version) }

      it_behaves_like "correct_pbm_dir_spec"
    end

    context '0.1.20.1をインストールするとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.1.20.1"] }
      let(:target_version) { decompress_procon_pbm_man_versions.first }

      subject { Pbmenv.install(target_version, enable_pbm_cloud: true) }

      include_examples "correct_pbm_dir_spec"

      it "URLの行がアンコメントアウトされていること" do
        subject
        target_version = decompress_procon_pbm_man_versions.first
        a_pbm_path = "/usr/share/pbm/v#{target_version}"
        expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  config.api_servers = 'https://pbm-cloud.herokuapp.com'$!)
      end
    end

    context '0.2.2をインストールするとき', :with_decompress_procon_pbm_man do
      let(:decompress_procon_pbm_man_versions) { ["0.2.2"] }
      let(:target_version) { decompress_procon_pbm_man_versions.first }

      context 'enable_pbm_cloud: true' do
        subject { Pbmenv.install(target_version, enable_pbm_cloud: true) }

        include_examples "correct_pbm_dir_spec"

        it "URLの行がアンコメントアウトされていること" do
          subject
          a_pbm_path = "/usr/share/pbm/v#{target_version}"
          expect(File.exist?("#{a_pbm_path}/app.rb.erb")).to eq(false)
          # 特定行をアンコメントしていること
          expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  config.api_servers = \['https://pbm-cloud.herokuapp.com'\]$!)
        end
      end

      context 'enable_pbm_cloud: false' do
        subject { Pbmenv.install(target_version, enable_pbm_cloud: false) }

        include_examples "correct_pbm_dir_spec"

        it "URLの行がコメントアウトされていること" do
          subject
          a_pbm_path = "/usr/share/pbm/v#{target_version}"
          expect(File.exist?("#{a_pbm_path}/app.rb.erb")).to eq(false)
          # 特定行をコメントアウトしていること
          expect(File.read("#{a_pbm_path}/app.rb")).to match(%r!^  # config.api_servers = \['https://pbm-cloud.herokuapp.com'\]$!)
        end
      end
    end
  end

  describe '.clean' do
    before do
      FakeVersionDirFactory.create('0.0.1', symlink_to_current: true)
      %w(
        0.10.1
        0.2.2
        0.2.3
        0.2.4
        0.2.5
        0.2.6
        0.2.7
        0.2.8
        0.2.11
        0.2.12
        0.2.13
        0.2.14
        0.2.15
        0.2.16
      ).each do |version_name|
        FakeVersionDirFactory.create(version_name)
      end
    end

    subject { Pbmenv.clean(keep_versions_size) }

    context '入力が残っているバージョンの数を超えているとき' do
      let(:keep_versions_size) { 20 }

      it '削除しない' do
        expect { subject }.not_to change { Pbmenv.installed_versions.size }
      end
    end

    context '入力が0のとき' do
      let(:keep_versions_size) { 0 }

      it '最新とcurrentを残す' do
        subject
        actual = Pbmenv.installed_versions
        expect(actual.size).to eq(2)
        expect(actual[0]).to have_attributes(latest_version?: false, current_version?: true, version_name: '0.0.1')
        expect(actual[1]).to have_attributes(latest_version?: true, current_version?: false, version_name: '0.10.1')
      end
    end

    context '入力が10のとき' do
      let(:keep_versions_size) { 5 }

      it '最新とcurrentを残す' do
        subject
        actual = Pbmenv.installed_versions
        expect(actual.size).to eq(7)
        expect(actual.map(&:name)).to eq(
          ["0.0.1", "0.2.2", "0.2.3", "0.2.4", "0.2.5", "0.2.6", "0.10.1"]
        )
      end
    end
  end
end
