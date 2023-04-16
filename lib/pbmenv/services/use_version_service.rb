# frozen_string_literal: true

module Pbmenv
  class UseVersionService
    class VersionNotFoundError < StandardError; end

    attr_accessor :version

    def initialize(version: )
      self.version = version
    end

    def execute!
      throw_error_if_has_not_version
      relink_current_path
    end

    private

    def throw_error_if_has_not_version
      version_pathname = VersionPathname.new(version)

      if !File.exist?(version_pathname.version_path_without_v) && !File.exist?(version_pathname.version_path)
        raise UseVersionService::VersionNotFoundError
      end
    end

    def relink_current_path
      version_pathname = VersionPathname.new(version)

      if File.symlink?(VersionPathname.current)
        Helper.system_and_puts "unlink #{VersionPathname.current}"
      end

      Helper.system_and_puts "ln -s #{version_pathname.version_path} #{VersionPathname.current}"
    end
  end
end
