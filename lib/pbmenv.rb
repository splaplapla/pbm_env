# frozen_string_literal: true

require "securerandom"
require "pathname"

require_relative "pbmenv/version"
require_relative "pbmenv/cli"
require_relative "pbmenv/pbm"
require_relative "pbmenv/helper"
require_relative "pbmenv/version_pathname"
require_relative "pbmenv/create_version_service"
require_relative "pbmenv/download_src_service"

module Pbmenv
  PBM_DIR = "/usr/share/pbm"

  def self.available_versions
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact
  end

  def self.versions
    Pbmenv::PBM.new.versions.map { |name| Pathname.new(name).basename.to_s =~ /^v([\d.]+)/ && $1 }.compact.sort_by {|x| Gem::Version.new(x) }.compact
  end

  def self.install(version, use_option: false, enable_pbm_cloud: false)
    raise "Need a version" if version.nil?
    version =
      if version == 'latest'
        available_versions.first
      else
        normalize_version(version)
      end

    begin
      CreateVersionService.new(version: version, use_option: use_option, enable_pbm_cloud: enable_pbm_cloud).execute!
    rescue CreateVersionService::AlreadyCreatedError
      return false
    rescue CreateVersionService::NotSupportVersionError
      raise
    end
  end

  # TODO currentが挿しているバージョンはどうする？
  def self.uninstall(version)
    raise "Need a version" if version.nil?

    unless File.exists?("/usr/share/pbm/v#{version}")
      return false
    end
    Helper.system_and_puts "rm -rf #{PBM_DIR}/v#{version}"
  end

  def self.use(version)
    raise "Need a version" if version.nil?
    version = versions.last if version == "latest"

    if !File.exists?("/usr/share/pbm/#{version}") && !File.exists?("/usr/share/pbm/v#{version}")
      return false
    end

    if File.symlink?("#{PBM_DIR}/current")
      Helper.system_and_puts "unlink #{PBM_DIR}/current"
    end

    if(version_number = normalize_version(version))
      Helper.system_and_puts "ln -s #{PBM_DIR}/v#{version_number} #{PBM_DIR}/current"
    else
      raise "mismatch version number!"
    end
  end

  def self.normalize_version(version)
    version.match(/v?([\w.]+)/)[1]
  end
end
