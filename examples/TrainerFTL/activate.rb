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
          puts "\n\nKilling enemies when 'Save Positions' is hit\n\n"
          crew_members = CrewMemberFactory.crew_list.select{|member| member.owner_ship != 0}

          crew_members.each do |member|
            puts "Set to kill #{member.name}"
            member.add_kill_trigger(0x1000ff42c)
          end
        when end_keycode
          puts "\n\nKilling everyone on enemy ship...\n\n"
          crew_members = CrewMemberFactory.crew_list

          crew_members.each do |member|
            if member.owner_ship != 0
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