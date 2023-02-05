require "spec_helper"

describe Pbmenv::PBM do
  describe "#available_versions" do
    it do
      expect(described_class.new.available_versions).to be_a(Array)
    end
  end
end
