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
    raise "Need a version" if sub_command_arg.nil?

    # curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v0.1.6.tar.gz | tar xvz
    # git clone https://github.com/splaplapla/procon_bypass_man.git -b v0.1.6 procon_bypass_man-0.1.6
    # git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-0.1.6
    shell = <<~SHELL
      git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-0.1.6
      mkdir -p #{PBM_DIR}/v#{version}
      cp -r procon_bypass_man-#{version}/project_template/* #{PBM_DIR}/v#{version}/
    SHELL
    system shell
    use version
  rescue => e
    system "rm -rf #{PBM_DIR}/v#{version}"
    raise
  end

  def self.uninstall(version)
    raise "Need a version" if sub_command_arg.nil?
  end

  def self.use(version)
    unless File.exists?("/usr/share/pbm/v#{version}")
      false
    end

    system "unlink #{PBM_DIR}/current"
    system "ln -s #{PBM_DIR}/current #{PBM_DIR}/v#{version}"
  end
end
