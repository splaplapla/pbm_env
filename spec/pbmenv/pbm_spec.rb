require "spec_helper"

describe Pbmenv::PBM do
  describe "#available_versions" do
    subject { Pbmenv.available_versions }

    it 'エラーが起きないこと' do
      # rate limitに引っかからないようにここだけは実際にapi callする
      allow(Pbmenv).to receive(:available_versions).and_call_original
      subject
    end
  end
end
