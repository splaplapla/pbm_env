module Pbmenv
  class VersionPathname
    attr_accessor :version

    def initialize(version)
      self.version = version
    end

    def version_path
      File.join(Pbmenv.pbm_dir, "v#{version}")
    end

    def version_path_without_v
      File.join(Pbmenv.pbm_dir, "#{version}")
    end

    def app_rb_path
      File.join(version_path, "app.rb")
    end

    def app_rb_erb_path
      File.join(version_path, "app.rb.erb")
    end

    def device_id_path_in_version
      File.join(version_path, "device_id")
    end

    def src_pbm_path
      File.join("/tmp", "procon_bypass_man-#{version}")
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

    def device_id_path_in_shared
      File.join(self.class.shared, "device_id")
    end

    def src_pbm_project_template_path
      File.join(src_pbm_path, "project_template")
    end

    def src_pbm_project_template_app_rb_erb_path
      File.join(src_pbm_project_template_path, "app.rb.erb")
    end

    def lib_app_generator
      File.join(src_pbm_project_template_path, "lib", "app_generator")
    end

    def src_project_template_systemd_units
      File.join(src_pbm_project_template_path, "systemd_units")
    end

    def self.device_id_path_in_shared
      File.join(shared, "device_id")
    end

    def self.current
      File.join(Pbmenv.pbm_dir, "current")
    end

    def self.shared
      File.join(Pbmenv.pbm_dir, "shared")
    end
  end
end
