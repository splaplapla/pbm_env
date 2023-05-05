require "spec_helper"

describe Pbmenv::CLI do
  describe '.run' do
    context 'when install' do
      subject { described_class.run(subject_args) }

      context '第1引数のみあるとき' do
        let(:subject_args) { ['install'] }

        it do
          expect(Pbmenv).to receive(:install).with(nil, use_option: false)
          expect(subject).to be_nil
        end
      end

      context '第2引数があるとき' do
        let(:subject_args) { ['install', 'foo'] }

        it do
          expect(Pbmenv).to receive(:install).with("foo", use_option: false)
          subject
        end
      end

      context '第1, 2, 3引数があるとき' do
        context '第3引数が--useのとき' do
          let(:subject_args) { ["install", "foo", "--use"]}

          it do
            expect(Pbmenv).to receive(:install).with("foo", use_option: true)
            subject
          end
        end

        context '第3引数が想定外のとき' do
          let(:subject_args) { ["install", "foo", "any"]}

          it 'エラーが起きる' do
            expect(Pbmenv).not_to receive(:install)
            expect { subject }.to raise_error(Pbmenv::CLI::CLIError)
          end
        end
      end
    end
  end
end
