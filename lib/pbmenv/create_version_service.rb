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

      begin
        source_path = download_src(version)
        build_app_file(source_path: source_path)
        create_if_miss_shared_dir
        create_if_miss_device_id_file
        link_device_id_file(version: version)
        create_if_miss_current_dir(version: version)
      rescue => e
        Helper.system_and_puts "rm -rf #{VersionPathname.new(version).version_path}"
        raise
      ensure
        if Dir.exists?(source_path)
          Helper.system_and_puts "rm -rf #{source_path}"
        end
      end
    end

    private

    # @return [String]
    def download_src(version)
      Pbmenv::DownloadSrcService.new(version).execute!
      return "procon_bypass_man-#{version}"
    end

    def build_app_file(source_path: )
      pathname = VersionPathname.new(version)

      if File.exists?(File.join(source_path, "project_template/app.rb.erb"))
        Helper.system_and_puts <<~SHELL
          mkdir -p #{pathname.version_path} &&
            cp procon_bypass_man-#{version}/project_template/app.rb.erb #{pathname.version_path}/
            cp procon_bypass_man-#{version}/project_template/README.md #{pathname.version_path}/
            cp procon_bypass_man-#{version}/project_template/setting.yml #{pathname.version_path}/
            cp -r procon_bypass_man-#{version}/project_template/systemd_units #{pathname.version_path}/
        SHELL
        require "./procon_bypass_man-#{version}/project_template/lib/app_generator"
        AppGenerator.new(
          prefix_path: pathname.version_path,
          enable_integration_with_pbm_cloud: enable_pbm_cloud,
        ).generate
        Helper.system_and_puts "rm #{pathname.app_rb_erb_path}"

      else
        Helper.system_and_puts <<~SHELL
          mkdir -p #{pathname.version_path} &&
            cp procon_bypass_man-#{version}/project_template/app.rb #{pathname.version_path}/
            cp procon_bypass_man-#{version}/project_template/README.md #{pathname.version_path}/
            cp procon_bypass_man-#{version}/project_template/setting.yml #{pathname.version_path}/
            cp -r procon_bypass_man-#{version}/project_template/systemd_units #{pathname.version_path}/
        SHELL
      end

      # 旧実装バージョン
      if enable_pbm_cloud
        text = File.read(pathname.app_rb_path)
        if text =~ /config\.api_servers\s+=\s+\['(https:\/\/.+)'\]/ && (url = $1)
          text.gsub!(/#\s+config\.api_servers\s+=\s+.+$/, "config.api_servers = '#{url}'")
        end
        File.write(pathname.app_rb_path, text)
      end
    end

    def create_if_miss_shared_dir
      unless File.exists?(VersionPathname.shared)
        Helper.system_and_puts <<~SHELL
          mkdir -p #{VersionPathname.shared}
        SHELL
      end
    end

    def create_if_miss_device_id_file
      device_id_path_in_shared = VersionPathname.device_id_path_in_shared
      unless File.exists?(device_id_path_in_shared)
        File.write(device_id_path_in_shared, "d_#{SecureRandom.uuid}")
      end
    end

    def link_device_id_file(version: )
      pathname = VersionPathname.new(version)
      Helper.system_and_puts <<~SHELL
        ln -s #{pathname.device_id_path_in_shared} #{pathname.device_id_path_in_version}
      SHELL
    end

    def create_if_miss_current_dir(version: )
      # 初回だけinstall時にcurrentを作成する
      if !File.exists?(VersionPathname.current) || use_option
        UseVersionService.new(version: version).execute!
      end
    end
  end
end
