# frozen_string_literal: true

require "securerandom"
require "pathname"

require_relative "pbmenv/version"
require_relative "pbmenv/cli"
require_relative "pbmenv/pbm"
require_relative "pbmenv/helper"
require_relative "pbmenv/version_pathname"
require_relative "pbmenv/version_object"
require_relative "pbmenv/directory_object"
require_relative "pbmenv/services/create_version_service"
require_relative "pbmenv/services/destroy_version_service"
require_relative "pbmenv/services/use_version_service"
require_relative "pbmenv/services/download_src_service"

module Pbmenv
  PBM_DIR = "/usr/share/pbm"

  # @return [Pbmenv::DirectoryObject]
  def self.current_directory
    Pbmenv::DirectoryObject.new(path: File.join(PBM_DIR, 'current'))
  end

  def self.available_versions
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact
  end

  # @return [Array<Pbmenv::VersionObject>]
  def self.installed_versions
    unsorted_dirs = Dir.glob("#{Pbmenv::PBM_DIR}/v*")
    sorted_version_names = unsorted_dirs.map { |name| Pathname.new(name).basename.to_s =~ /^v([\d.]+)/ && $1 }.compact.sort_by {|x| Gem::Version.new(x) }
    sorted_version_names.map do |version_name|
      VersionObject.new(
        version_name: version_name,
        is_latest: sorted_version_names.last == version_name,
        is_current: Pbmenv.current_directory.readlink&.end_with?(version_name),
      )
    end
  end

  # @deprecated
  def self.versions
    unsorted_dirs = Dir.glob("#{Pbmenv::PBM_DIR}/v*")
    unsorted_dirs.map { |name| Pathname.new(name).basename.to_s =~ /^v([\d.]+)/ && $1 }.compact.sort_by {|x| Gem::Version.new(x) }.compact
  end

  def self.install(version, use_option: false, enable_pbm_cloud: false)
    raise "Need a version" if version.nil?
    version =
      if version == 'latest'
        available_versions.first
      else
        Helper.normalize_version(version) or raise "mismatch version number!"
      end

    begin
      CreateVersionService.new(version: version, use_option: use_option, enable_pbm_cloud: enable_pbm_cloud).execute!
    rescue CreateVersionService::AlreadyCreatedError
      return false
    rescue CreateVersionService::NotSupportVersionError
      return false
    end
  end

  # TODO currentが挿しているバージョンはどうする？
  def self.uninstall(version)
    raise "Need a version" if version.nil?
    version = Helper.normalize_version(version) or raise "mismatch version number!"

    begin
      DestroyVersionService.new(version: version).execute!
    rescue DestroyVersionService::VersionNotFoundError
      return false
    end
  end

  def self.use(version)
    raise "Need a version" if version.nil?
    version =
      if version == 'latest'
        versions.last
      else
        Helper.normalize_version(version) or raise "mismatch version number!"
      end

    begin
      UseVersionService.new(version: version).execute!
    rescue UseVersionService::VersionNotFoundError
      return false
    end
  end
end
