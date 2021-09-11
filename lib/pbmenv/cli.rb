module Pbmenv
  class CLI
    def self.run(argv)
      sub_command = argv[0]
      case sub_command
      when 'available_versions', 'av'
        Pbmenv.available_versions.each { |x| puts x }
      when 'versions', 'list'
        Pbmenv.versions.each { |x| puts x }
      when 'install', 'i'
        sub_command_arg = argv[1]
        Pbmenv.install(sub_command_arg)
      when 'uninstall'
        sub_command_arg = argv[1]
        Pbmenv.uninstall(sub_command_arg)
      end
    end
  end
end
