module Pbmenv
  class DownloadSrcService
    class DownloadError < StandardError; end

    attr_accessor :version

    def initialize(version)
      self.version = version
    end

    def execute!
      pathname = VersionPathname.new(version)
      pathname.src_pbm_path
      if ENV["DEBUG_INSTALL"]
        shell = <<~SHELL
          git clone https://github.com/splaplapla/procon_bypass_man.git #{pathname.src_pbm_path}
        SHELL
      else
        # TODO cache for testing
        shell = <<~SHELL
          curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz | tar xvz -C /tmp > /dev/null
        SHELL
      end

      if Helper.system_and_puts(shell)
        unless File.exist?(pathname.src_pbm_project_template_path)
          raise NotSupportVersionError, "This version is not support by pbmenv"
        end
      else
        raise DownloadError
      end
    end
  end
end
