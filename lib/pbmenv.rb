# frozen_string_literal: true

require_relative "pbmenv/version"
require_relative "pbmenv/cli"
require_relative "pbmenv/pbm"

module Pbmenv
  class Error < StandardError; end
  PBM_DIR = "/usr/share/pbm"

  def self.init
    "mkdir -p #{PBM_DIR}"
  end

  def self.available_versions
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact
  end

  def self.versions
    Pbmenv::PBM.new.versions.map { |name| name =~ /^v([\d.]+)/ && $1 }.compact
  end

  def self.install(version)
    raise "Need a version" if version.nil?

    # curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v0.1.6.tar.gz | tar xvz
    # git clone https://github.com/splaplapla/procon_bypass_man.git -b v0.1.6 procon_bypass_man-0.1.6
    # git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-0.1.6
    if ENV["DEBUG_INSTALL"]
      shell = <<~SHELL
        git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-#{version}
      SHELL
    else
      shell = <<~SHELL
        curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz | tar xvz
      SHELL
    end
    system_with_puts(shell)
    unless File.exists?("procon_bypass_man-#{version}/project_template")
      raise "This version is not support by pbmenv"
    end

    system_with_puts <<~SHELL
      mkdir -p #{PBM_DIR}/v#{version}
      cp -r procon_bypass_man-#{version}/project_template/* #{PBM_DIR}/v#{version}/
    SHELL
    use version
  rescue => e
    system_with_puts "rm -rf #{PBM_DIR}/v#{version}"
    raise
  ensure
    system_with_puts "rm -rf procon_bypass_man-#{version}"
  end

  def self.uninstall(version)
    raise "Need a version" if version.nil?
  end

  def self.use(version)
    unless File.exists?("/usr/share/pbm/v#{version}")
      return false
    end

    if File.exists?("#{PBM_DIR}/current")
      system_with_puts "unlink #{PBM_DIR}/current"
    end
    system_with_puts "ln -s #{PBM_DIR}/v#{version} #{PBM_DIR}/current"
  end

  def self.system_with_puts(shell)
    puts "[SHELL] #{shell}"
    system(shell)
  end
end
