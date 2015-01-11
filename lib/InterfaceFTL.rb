require 'OSXMemory'
require_relative "InterfaceFTL/CrewMember"
require_relative "InterfaceFTL/CrewMemberFactory"

module InterfaceFTL
  @pid = nil
  @instance = nil
  @function_id = 0

  def self.hook(pid)
    @pid = pid
    @instance = OSXMemory.task_for_pid @pid
    @instance.attach
  end

  def self.instance; @instance; end
  def self.process_loop; @instance.process_loop; end

  def self.add_function_call(addr, fnc_addr, args)
    breakpoint_size = OSXMemory::Breakpoint::INT3.size
    @function_id

    start_breakpoint = @instance.add_breakpoint(addr) do |thread, options|
      original_values = {}

      new_state = thread.state

      addr_ptr = [addr].pack('Q')
      new_state.rsp -= addr_ptr.size
      @instance.write(new_state.rsp, addr_ptr)

      # Set up the function arguments
      args.each do |arg|
        original_values[arg[:register]] = new_state.send(arg[:register].to_s)
        new_state.send(arg[:register].to_s + '=', arg[:value])
      end

      new_state.rip = fnc_addr
      thread.save_state(new_state)

      options[:return_cleanup] = Proc.new do |thread, options|
        original_state = thread.state
        original_values.each {|register, value| original_state.send(register.to_s + '=', value)}
        original_state.rip = addr+1
        thread.save_state(original_state)
      end
    end

    start_breakpoint.execute_alone = true
  end

end