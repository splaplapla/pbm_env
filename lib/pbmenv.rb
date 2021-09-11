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
    Pbmenv::PBM.new.available_versions.map { |x| x["name"] =~ /^v([\d.]+)/ && $1 }.compact.each do |v|
      puts v
    end
  end

  def self.versions
    Pbmenv::PBM.new.versions.map { |name| name =~ /^v([\d.]+)/ && $1 }.compact.each do |v|
      puts v
    end
  end

  def self.install(version)
  end

  def self.uninstall(version)
    # TODO
  end
end
