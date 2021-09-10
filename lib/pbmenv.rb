# frozen_string_literal: true

require_relative "pbmenv/version"

module Pbmenv
  class Error < StandardError; end
  # Your code goes here...

  def self.init
    "mkdir -p /usr/share/pbm"
  end

  def self.available_pbm_versions
  end

  def self.installed_pbm_versions
  end

  def self.install(version)
  end
end
