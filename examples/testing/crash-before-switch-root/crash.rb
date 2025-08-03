class Tasks::Crash < SingletonTask
  def initialize()
    # Runs before SwitchRoot
    Targets[:SwitchRoot].add_dependency(:Task, self)
    add_dependency(:Target, :Graphics)
  end

  def run()
    passphrase = Progress.ask("Passphrase for nothing...")
    Progress.exec_with_message("Waiting for testing...") do
      sleep(10)
    end
  end
end
