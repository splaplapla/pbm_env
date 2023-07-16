# frozen_string_literal: true

require "securerandom"
require "pathname"
require "logger"

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
  PBM_DIR = "/usr/share/pbm" # NOTE: pbmから参照している
  DEFAULT_PBM_DIR = PBM_DIR

  @current_pbm_dir = DEFAULT_PBM_DIR
  @logger = Logger.new($stdout)
  @logger.formatter = proc do |severity, datetime, progname, message|
    "#{message}\n"
  end

  class << self
    attr_accessor :logger
  end

  # @param [String] to_dir
  # @return [void]
  # NOTE: テスト用
  def self.chdir(to_dir)
    raise(ArgumentError, 'テスト以外では実行できません') unless defined?(RSpec)
    @current_pbm_dir = to_dir
  end

  # @return [String]
  def self.pbm_dir
    @current_pbm_dir
  end

  # @return [void]
  def self.slice_logger
    previous_logger = self.logger
    self.logger = Logger.new(nil)
    yield
    self.logger = previous_logger
  end

  # @return [Pbmenv::DirectoryObject]
  def self.current_directory
    Pbmenv::DirectoryObject.new(path: VersionPathname.current)
  end

  def self.available_versions
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact
  end

  # @return [Array<Pbmenv::VersionObject>]
  def self.installed_versions
    unsorted_dirs = Dir.glob("#{Pbmenv.pbm_dir}/v*")
    sorted_version_names = unsorted_dirs.map { |name| Pathname.new(name).basename.to_s =~ /^v([\d.]+)/ && $1 }.compact.sort_by {|x| Gem::Version.new(x) }
    sorted_version_names.map do |version_name|
      VersionObject.new(
        version_name: version_name,
        is_latest: sorted_version_names.last == version_name,
        is_current: Pbmenv.current_directory.readlink&.end_with?(version_name) || false,
      )
    end
  end

  def self.command_versions
    self.installed_versions.map do |version|
      version.current_version? ? "* #{version.name}" : " #{version.name}"
    end
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

  # TODO: 引数がcurrentを指しているバージョンはどうする？
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
        self.installed_versions.last.name
      else
        Helper.normalize_version(version) or raise "mismatch version number!"
      end

    begin
      UseVersionService.new(version: version).execute!
    rescue UseVersionService::VersionNotFoundError
      return false
    end
  end

  # @param [Integer] keep_versions_size
  # @return [void]
  def self.clean(keep_versions_size)
    raise ArgumentError if keep_versions_size.nil?

    clean_targets = self.installed_versions[(keep_versions_size + 1)..-1]
    return if clean_targets.nil?

    clean_targets.each do |version_object|
      next if(version_object.latest_version? or version_object.current_version?)
      self.uninstall(version_object.name)
    end
  end
end
