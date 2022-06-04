RSpec.shared_examples 'correct_pbm_dir_spec' do
  let(:target_version) { raise "Require target_version" }

  it '/usr/share/pbm/v#{target_version}/ にファイルを作成すること' do
    subject
    expect(Dir.exists?("/usr/share/pbm/v#{target_version}")).to eq(true)
    expect(File.exists?("/usr/share/pbm/v#{target_version}/app.rb")).to eq(true)
  end

  it '/usr/share/pbm/v#{target_version}/device_idを作成すること' do
    subject
    expect(File.readlink("/usr/share/pbm/v#{target_version}/device_id")).to eq("/usr/share/pbm/shared/device_id")
  end

  it '/usr/share/pbm/shared/device_idを作成すること' do
    subject
    expect(File.read("/usr/share/pbm/shared/device_id")).to be_a(String)
  end

  it '解凍したファイルを削除していること' do
    subject
    target_version = decompress_procon_pbm_man_versions.first
    expect(Dir.exists?("procon_bypass_man-#{target_version}")).to eq(false)
  end
end
