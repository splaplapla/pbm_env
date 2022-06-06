# frozen_string_literal: true

module Pbmenv
  class DestroyVersionService
    class VersionNotFoundError < StandardError; end

    attr_accessor :version

    def initialize(version: )
      @version = version
    end

    def execute!
      version_pathname = VersionPathname.new(version)

      unless File.exists?(version_pathname.version_path)
        raise VersionNotFoundError
      end
      Helper.system_and_puts "rm -rf #{version_pathname.version_path}"
    end
  end
end
