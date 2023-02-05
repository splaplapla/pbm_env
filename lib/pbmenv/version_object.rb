module Pbmenv
  class VersionObject
    # @param [String] version_name
    # @param [Boolean] is_latest
    # @param [Boolean] is_current
    def initialize(version_name: , is_latest: , is_current: )
      @version_name = version_name
      @is_latest = is_latest
      @is_current = is_current
    end

    # @return [String]
    def version_name
      @version_name
    end

    # @return [Boolean]
    def current_version?
      @is_current
    end

    # @return [Boolean]
    def latest_version?
      @is_latest
    end
  end
end
