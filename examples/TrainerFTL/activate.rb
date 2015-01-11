#!/usr/bin/env ruby
require 'InterfaceFTL'
require 'sys/proctable'

class TrainerFTL
  include InterfaceFTL

  def hook
    matches = Sys::ProcTable.ps.select{|p| p.comm =~ /^FTL$/ }
    abort("No PID") if matches.empty?
    pid = matches.first.pid

    puts "Attaching to PID: #{pid}"
    InterfaceFTL.hook pid
  end

  def activate
    keypress_offset = 0x10013ba18

    crew_members = CrewMemberFactory.crew_list

    InterfaceFTL.instance.add_breakpoint(0x1000ccc8c) do |thread|
      puts "HIT KILL CREWMEMBER"
      puts thread.state.dump
    end

    InterfaceFTL.instance.add_breakpoint(keypress_offset) do |thread|
      tilde_keycode = 0x60
      home_keycode = 0x116
      end_keycode = 0x117

      case thread.state.r14
        when tilde_keycode
          puts "\n\n----- Game Report -----\n"
          puts "Player controls #{CrewMemberFactory.player_crew_count} crew members"
          puts "Player controls #{CrewMemberFactory.enemy_crew_count} enemy crew members"
          crew_members = CrewMemberFactory.crew_list

          crew_members.each {|member|
            puts "\n----- Member Report -----"
            puts "Name: #{member.name}"
            puts "Health: #{member.health}"
            puts "Provides Vision?: #{member.provides_vision?}"
            puts "Species: #{member.species}"
            puts "Position: (#{member.position_x}, #{member.position_y})"
            puts "World Position: (#{member.world_position_x}, #{member.world_position_y})"
            puts "Owner Ship: #{member.owner_ship}"
            puts "Boarded Ship: #{member.boarded_ship}"
            puts "Room Number: #{member.room_number}"
            puts "Room Position: (#{member.room_x}, #{member.room_y})"
            puts "Ship Address: #{member.ship_address.to_s(16)}"
          }
        when home_keycode
          puts "\n\nTaking control of all enemy crew members...\n\n"
          crew_members = CrewMemberFactory.crew_list
          safe_member = crew_members.select {|member| member.boarded_ship == 0 }.first if crew_members.size > 0

          crew_members.each do |member|
            args = [
              {register: :rdi, value: member.base_offset}
            ]

            InterfaceFTL.add_function_call(0x1000ff42c, 0x1000ccc8c, args)
          end
        when end_keycode
          puts "\n\nKilling everyone on enemy ship...\n\n"
          crew_members = CrewMemberFactory.crew_list

          crew_members.each do |member|
            if member.boarded_ship != 0
              member.health = 0
            end
          end
        else
          puts "Unknown key hit. Code: #{thread.state.r14.to_s(16)}"
      end
    end
  end

  def process; InterfaceFTL.process_loop; end
end

trainer = TrainerFTL.new
trainer.hook
trainer.activate
trainer.process