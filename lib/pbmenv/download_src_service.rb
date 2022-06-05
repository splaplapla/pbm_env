module Pbmenv
  class DownloadSrcService
    class DownloadError < StandardError; end

    attr_accessor :version

    def initialize(version)
      self.version = version
    end

    def execute!
      if ENV["DEBUG_INSTALL"]
        shell = <<~SHELL
        git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-#{version}
        SHELL
      else
        # TODO cache for testing
        shell = <<~SHELL
        curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz | tar xvz > /dev/null
        SHELL
      end

      if Helper.system_and_puts(shell)
        unless File.exists?("procon_bypass_man-#{version}/project_template")
          raise NotSupportVersionError, "This version is not support by pbmenv"
        end
      else
        raise DownloadError
      end
    end
  end
end
