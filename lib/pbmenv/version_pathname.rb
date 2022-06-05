module Pbmenv
  class VersionPathname
    PBM_DIR = "/usr/share/pbm"

    def initialize(version)
      @version = version
    end

    def version_path
      File.join(PBM_DIR, "/v#{@version}")
    end

    def app_rb_path
      File.join(PBM_DIR, "/v#{@version}", "app.rb")
    end

    def app_rb_erb_path
      File.join(PBM_DIR, "/v#{@version}", "app.rb.erb")
    end

    def device_id_path_in_version
      File.join(PBM_DIR, "/v#{@version}", "/device_id")
    end

    def device_id_path_in_shared
      File.join(PBM_DIR, "/shared", "/device_id")
    end

    def self.device_id_path_in_shared
      File.join(PBM_DIR, "/shared", "/device_id")
    end

    def self.current
      File.join(PBM_DIR, "/current")
    end

    def self.shared
      File.join(PBM_DIR, "/shared")
    end
  end
end
