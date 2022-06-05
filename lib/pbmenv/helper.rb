module Pbmenv
  class Helper
    def self.system_and_puts(shell)
      to_stdout "[SHELL] #{shell}"
      system(shell)
    end

    def self.to_stdout(text)
      puts text
    end
  end
end
