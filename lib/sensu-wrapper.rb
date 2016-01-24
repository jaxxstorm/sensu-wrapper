
Module SensuWrapper

  def self.die(code = 0, msg = nil)
    at_exit { puts msg }
    Kernel.exit(code)
  end

end
