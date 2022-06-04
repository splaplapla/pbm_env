RSpec.shared_context 'decompress_procon_pbm_man' do
  let(:decompress_procon_pbm_man_versions) { raise "need version" }

  before(:each) do
    allow(Pbmenv).to receive(:download_src)
  end

  around(:each) do |example|
    decompress_procon_pbm_man_versions.each do |version|
      system "tar zxvf ./spec/files/procon_bypass_man-#{version}.tar.gz > /dev/null"
    end

    example.run

    decompress_procon_pbm_man_versions.each do |version|
      system "rm -rf procon_bypass_man-#{version}"
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "decompress_procon_pbm_man", :with_decompress_procon_pbm_man
end
