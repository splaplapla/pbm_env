# frozen_string_literal: true

require 'open-uri'
require 'json'

module Pbmenv
  class PBM
    # @return [Array<String>] githubに問い合わせて、利用可能なバージョンのリストを返す
    def available_versions
      response = URI.open 'https://api.github.com/repos/splaplapla/procon_bypass_man/tags'
      JSON.parse(response.read)
    end
  end
end
