module FakeVersionDirFactory
  # @param [String]
  def self.create(version_name, symlink_to_current: false)
    `mkdir -p #{Pbmenv.pbm_dir}/v#{version_name}`

    if symlink_to_current
      `ln -s #{Pbmenv.pbm_dir}/v#{version_name} #{Pbmenv.current_directory.path}`
    end
  end
end
