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
        case argv[2]
        when "--use"
          use_option = true
        when nil
          use_option = false
        else
          puts <<~EOH
            Unknown option:
              available options: --use
          EOH
        end
        Pbmenv.install(sub_command_arg, use_option: use_option)
      when 'use', 'u'
        sub_command_arg = argv[1]
        Pbmenv.use(sub_command_arg)
      when 'uninstall'
        sub_command_arg = argv[1]
        Pbmenv.uninstall(sub_command_arg)
      when '--version'
        puts Pbmenv::VERSION
      else
        puts <<~EOH
          Unknown command:
            available commands: available_versions, versions, install, use, uninstall
        EOH
      end
    end
  end
end
