require "spec_helper"

describe Pbmenv::Helper do
  describe '.normalize_version' do
    context 'vなし' do
      it do
        expect(described_class.normalize_version("0.1.1")).to eq("0.1.1")
      end
    end

    context 'vあり' do
      it do
        expect(described_class.normalize_version("v0.1.1")).to eq("0.1.1")
      end
    end

    context 'slashあり' do
      it do
        expect(described_class.normalize_version("0/1.1")).to eq(nil)
      end
    end

    context 'dotなし' do
      it do
        expect(described_class.normalize_version("011")).to eq("011")
      end
    end
  end
end
