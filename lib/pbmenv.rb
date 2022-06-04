# frozen_string_literal: true

require "securerandom"

require_relative "pbmenv/version"
require_relative "pbmenv/cli"
require_relative "pbmenv/pbm"

module Pbmenv
  PBM_DIR = "/usr/share/pbm"

  def self.available_versions
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact
  end

  def self.versions
    Pbmenv::PBM.new.versions.map { |name| Pathname.new(name).basename.to_s =~ /^v([\d.]+)/ && $1 }.compact
  end

  def self.install(version)
    raise "Need a version" if version.nil?
    if version == 'latest'
      version = available_versions.first
    end

    if File.exists?("/usr/share/pbm/v#{version}")
      return false
    end

    download_src(version)

    if File.exists?(File.join("procon_bypass_man-#{version}/", "project_template/app.rb.erb"))
      system_and_puts <<~SHELL
        mkdir -p #{PBM_DIR}/v#{version} &&
          cp procon_bypass_man-#{version}/project_template/app.rb.erb #{PBM_DIR}/v#{version}/
          cp procon_bypass_man-#{version}/project_template/README.md #{PBM_DIR}/v#{version}/
          cp procon_bypass_man-#{version}/project_template/setting.yml #{PBM_DIR}/v#{version}/
          cp -r procon_bypass_man-#{version}/project_template/systemd_units #{PBM_DIR}/v#{version}/
      SHELL
      require "./procon_bypass_man-#{version}/project_template/lib/app_generator"

      AppGenerator.new(
        prefix_path: "#{PBM_DIR}/v#{version}/",
        enable_integration_with_pbm_cloud: true,
      ).generate
      system_and_puts "rm #{PBM_DIR}/v#{version}/app.rb.erb"
    else
      system_and_puts <<~SHELL
        mkdir -p #{PBM_DIR}/v#{version} &&
          cp procon_bypass_man-#{version}/project_template/app.rb #{PBM_DIR}/v#{version}/
          cp procon_bypass_man-#{version}/project_template/README.md #{PBM_DIR}/v#{version}/
          cp procon_bypass_man-#{version}/project_template/setting.yml #{PBM_DIR}/v#{version}/
          cp -r procon_bypass_man-#{version}/project_template/systemd_units #{PBM_DIR}/v#{version}/
      SHELL
    end

    unless File.exists?("#{PBM_DIR}/shared")
      system_and_puts <<~SHELL
        mkdir -p #{PBM_DIR}/shared
      SHELL
    end

    unless File.exists?("#{PBM_DIR}/shared/device_id")
      File.write("#{PBM_DIR}/shared/device_id", "d_#{SecureRandom.uuid}")
    end

    system_and_puts <<~SHELL
      ln -s #{PBM_DIR}/shared/device_id #{PBM_DIR}/v#{version}/device_id
    SHELL
  rescue => e
    system_and_puts "rm -rf #{PBM_DIR}/v#{version}"
    raise
  ensure
    if Dir.exists?("./procon_bypass_man-#{version}")
      system_and_puts "rm -rf ./procon_bypass_man-#{version}"
    end
  end

  # TODO currentが挿しているバージョンはどうする？
  def self.uninstall(version)
    raise "Need a version" if version.nil?

    unless File.exists?("/usr/share/pbm/v#{version}")
      return false
    end
    system_and_puts "rm -rf #{PBM_DIR}/v#{version}"
  end

  def self.use(version)
    raise "Need a version" if version.nil?

    unless File.exists?("/usr/share/pbm/v#{version}")
      return false
    end

    if File.exists?("#{PBM_DIR}/current")
      system_and_puts "unlink #{PBM_DIR}/current"
    end
    system_and_puts "ln -s #{PBM_DIR}/v#{version} #{PBM_DIR}/current"
  end

  def self.download_src(version)
    if ENV["DEBUG_INSTALL"]
      shell = <<~SHELL
        git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-#{version}
      SHELL
    else
      # TODO cache for testing
      shell = <<~SHELL
        curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz | tar xvz
      SHELL
    end

    system_and_puts(shell)
    unless File.exists?("procon_bypass_man-#{version}/project_template")
      raise "This version is not support by pbmenv"
    end
  end

  def self.system_and_puts(shell)
    puts "[SHELL] #{shell}"
    system(shell)
  end
end
