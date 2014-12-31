require 'OSXMemory'
require_relative "InterfaceFTL/CrewMember"
require_relative "InterfaceFTL/CrewMemberFactory"

module InterfaceFTL
  @pid = nil
  @instance = nil

  def self.hook(pid)
    @pid = pid
    @instance = OSXMemory.task_for_pid @pid
    @instance.attach
  end

  def self.instance; @instance; end
  def self.process_loop; @instance.process_loop; end

end