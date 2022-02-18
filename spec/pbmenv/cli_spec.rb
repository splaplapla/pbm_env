require "spec_helper"

describe Pbmenv::CLI do
  describe '.run' do
    context 'when install' do
      context '第2引数がないとき' do
        it do
          expect(Pbmenv).to receive(:install)
          expect(described_class.run(["install"])).to be_nil
        end
      end

      context '第2引数があるとき' do
        it do
          expect(Pbmenv).to receive(:install).with("foo", use_option: false)
          described_class.run(["install", "foo"])
        end
      end

      context '第1, 2, 3引数があるとき' do
        it do
          expect(Pbmenv).to receive(:install).with("foo", use_option: true)
          described_class.run(["install", "foo", "--use"])
        end
      end
    end
  end
end
