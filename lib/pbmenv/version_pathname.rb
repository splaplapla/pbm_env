module Pbmenv
  class VersionPathname
    PBM_DIR = "/usr/share/pbm"

    def initialize(version)
      @version = version
    end

    def version_path
      File.join(PBM_DIR, "/v#{@version}")
    end

    def version_path_without_v
      File.join(PBM_DIR, "/#{@version}")
    end

    def app_rb_path
      File.join(version_path, "app.rb")
    end

    def app_rb_erb_path
      File.join(version_path, "app.rb.erb")
    end

    def device_id_path_in_version
      File.join(version_path, "/device_id")
    end

    def src_pbm_path
      File.join("/tmp", "procon_bypass_man-#{@version}")
    end

    def project_template_file_paths(include_app_erb: )
      paths = ["README.md", "setting.yml"]
      if include_app_erb
        paths << "app.rb.erb"
      else
        paths << "app.rb"
      end
      return paths.map { |path| File.join(src_pbm_project_template_path, path) }
    end

    def src_pbm_project_template_path
      File.join(src_pbm_path, "project_template")
    end

    def src_pbm_project_template_app_rb_erb_path
      File.join(src_pbm_project_template_path, "app.rb.erb")
    end

    def device_id_path_in_shared
      File.join(self.class.shared, "/device_id")
    end

    def self.device_id_path_in_shared
      File.join(shared, "/device_id")
    end

    def self.current
      File.join(PBM_DIR, "/current")
    end

    def self.shared
      File.join(PBM_DIR, "/shared")
    end
  end
end
