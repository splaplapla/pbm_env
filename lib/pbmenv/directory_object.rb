module Pbmenv
  class DirectoryObject
    class NonSymlinkError < StandardError; end

    def initialize(path: )
      @path = path
    end

    def path
      @path
    end

    # @return [String]
    def readlink!
      raise NonSymlinkError if not symlink?
      File.readlink(path)
    end

    # @return [String, NilClass]
    def readlink
      readlink!
    rescue NonSymlinkError
      nil
    end

    private

    # @return [Boolean]
    def symlink?
      File.symlink?(path)
    end
  end
end
