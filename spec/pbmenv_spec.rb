require "spec_helper"

describe Pbmenv do
  before do
    raise("ファイルを読み書きするのでmacではやらない方がいいです") unless ENV["CI"]
  end
  before(:all) do
    system "unzip ./spec/files/procon_bypass_man-0.1.6.zip"
  end

  describe '.install' do
    it do
    end
  end
end
