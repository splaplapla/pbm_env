RSpec.shared_examples 'correct_pbm_dir_spec' do
  it '#{Pbmenv.pbm_dir}/v#{target_version}/ にファイルを作成すること' do
    subject
    a_pbm_path = "#{Pbmenv.pbm_dir}/v#{target_version}"
    expect(Dir.exist?("#{Pbmenv.pbm_dir}/v#{target_version}")).to eq(true)
    expect(File.exist?("#{Pbmenv.pbm_dir}/v#{target_version}/app.rb")).to eq(true)
    expect(File.exist?("#{a_pbm_path}/README.md")).to eq(true)
    expect(File.exist?("#{a_pbm_path}/setting.yml")).to eq(true)
    expect(File.exist?("#{a_pbm_path}/systemd_units/pbm.service")).to eq(true)
  end

  it '#{Pbmenv.pbm_dir}/v#{target_version}/device_idを作成すること' do
    subject
    expect(File.readlink("#{Pbmenv.pbm_dir}/v#{target_version}/device_id")).to eq("#{Pbmenv.pbm_dir}/shared/device_id")
  end

  it '#{Pbmenv.pbm_dir}/shared/device_idを作成すること' do
    subject
    expect(File.read("#{Pbmenv.pbm_dir}/shared/device_id")).to be_a(String)
  end

  it '解凍したファイルを削除していること' do
    subject
    target_version = decompress_procon_pbm_man_versions.first
    expect(Dir.exist?("procon_bypass_man-#{target_version}")).to eq(false)
  end

  it 'uninstallしたらディレクトリを消す' do
    subject
    Pbmenv.uninstall(target_version)
    expect(Dir.exist?(target_version)).to eq(false)
  end

  it 'もう一度installしてもエラーにならない' do
    subject
    expect { Pbmenv.install(target_version) }.not_to raise_error
  end
end
