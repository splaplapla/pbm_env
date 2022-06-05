# frozen_string_literal: true

module Pbmenv
  class CreateVersionService
    class AlreadyCreatedError < StandardError; end
    class NotSupportVersionError < StandardError; end

    attr_accessor :version, :use_option, :enable_pbm_cloud

    def initialize(version: , use_option: , enable_pbm_cloud: )
      self.version = version
      self.use_option = use_option
      self.enable_pbm_cloud = enable_pbm_cloud
    end

    def execute!
      if File.exists?("/usr/share/pbm/v#{version}")
        raise AlreadyCreatedError
      end

      source_path = download_src(version)
      build_app_file(source_path: source_path)
      create_if_miss_shared_dir
      create_if_miss_device_id_file
      link_device_id_file(version: version)
      create_if_miss_current_dir(version: version)
    rescue => e
      system_and_puts "rm -rf #{PBM_DIR}/v#{version}"
      raise
    ensure
      if Dir.exists?(source_path)
        system_and_puts "rm -rf #{source_path}"
      end
    end

    private

    # @return [String]
    def download_src(version)
      if ENV["DEBUG_INSTALL"]
        shell = <<~SHELL
        git clone https://github.com/splaplapla/procon_bypass_man.git procon_bypass_man-#{version}
        SHELL
      else
        # TODO cache for testing
        shell = <<~SHELL
        curl -L https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz | tar xvz > /dev/null
        SHELL
      end

      system_and_puts(shell)

      unless File.exists?("procon_bypass_man-#{version}/project_template")
        raise NotSupportVersionError, "This version is not support by pbmenv"
      end

      return "procon_bypass_man-#{version}"
    end

    def build_app_file(source_path: )
      if File.exists?(File.join("procon_bypass_man-#{version}/", "project_template/app.rb.erb"))
        system_and_puts <<~SHELL
          mkdir -p #{PBM_DIR}/v#{version} &&
            cp procon_bypass_man-#{version}/project_template/app.rb.erb #{PBM_DIR}/v#{version}/
            cp procon_bypass_man-#{version}/project_template/README.md #{PBM_DIR}/v#{version}/
            cp procon_bypass_man-#{version}/project_template/setting.yml #{PBM_DIR}/v#{version}/
            cp -r procon_bypass_man-#{version}/project_template/systemd_units #{PBM_DIR}/v#{version}/
        SHELL
        require "./procon_bypass_man-#{version}/project_template/lib/app_generator"
        AppGenerator.new(
          prefix_path: "#{PBM_DIR}/v#{version}/",
          enable_integration_with_pbm_cloud: enable_pbm_cloud,
        ).generate
        system_and_puts "rm #{PBM_DIR}/v#{version}/app.rb.erb"
      else
        system_and_puts <<~SHELL
          mkdir -p #{PBM_DIR}/v#{version} &&
            cp procon_bypass_man-#{version}/project_template/app.rb #{PBM_DIR}/v#{version}/
            cp procon_bypass_man-#{version}/project_template/README.md #{PBM_DIR}/v#{version}/
            cp procon_bypass_man-#{version}/project_template/setting.yml #{PBM_DIR}/v#{version}/
            cp -r procon_bypass_man-#{version}/project_template/systemd_units #{PBM_DIR}/v#{version}/
        SHELL
      end

      # 旧実装バージョン
      if enable_pbm_cloud
        text = File.read("#{PBM_DIR}/v#{version}/app.rb")
        if text =~ /config\.api_servers\s+=\s+\['(https:\/\/.+)'\]/ && (url = $1)
          text.gsub!(/#\s+config\.api_servers\s+=\s+.+$/, "config.api_servers = '#{url}'")
        end
        File.write("#{PBM_DIR}/v#{version}/app.rb", text)
      end
    end

    def create_if_miss_shared_dir
      unless File.exists?(VersionPathname.shared)
        system_and_puts <<~SHELL
          mkdir -p #{VersionPathname.shared}
        SHELL
      end
    end

    def create_if_miss_device_id_file
      device_id_path_in_shared = VersionPathname.device_id_in_shared
      unless File.exists?(device_id_path_in_shared)
        File.write(device_id_path_in_shared, "d_#{SecureRandom.uuid}")
      end
    end

    def link_device_id_file(version: )
      pathname = VersionPathname.new(version)
      system_and_puts <<~SHELL
        ln -s #{pathname.device_id_in_shared} #{pathname.device_id_in_version}
      SHELL
    end

    def create_if_miss_current_dir(version: )
      # 初回だけinstall時にcurrentを作成する
      if !File.exists?(VersionPathname.current) || use_option
        Pbmenv.use(version)
      end
    end

    def system_and_puts(shell)
      to_stdout "[SHELL] #{shell}"
      system(shell)
    end

    def to_stdout(text)
      puts text
    end
  end
end
