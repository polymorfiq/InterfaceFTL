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

    InterfaceFTL.instance.add_breakpoint(keypress_offset) do |thread|
      tilde_keycode = 0x60
      home_keycode = 0x116

      case thread.state.r14
        when tilde_keycode
          puts "\n\n----- Game Report -----\n"
          puts "Player controls #{CrewMemberFactory.player_crew_count} crew members"
          puts "Player controls #{CrewMemberFactory.enemy_crew_count} enemy crew members"
          crew_members = CrewMemberFactory.crew_list

          crew_members.each {|member|
            puts "\n----- Member Report -----"
            puts "Member Species: #{member.species}"
            puts "Member Position: (#{member.position.x}, #{member.position.y})"
            puts "Member Ship: #{member.ship_number}"
            puts "Member Boarded Ship: #{member.boarded_ship_number}"
          }
        when home_keycode
          puts "\n\nTaking control of all enemy crew members...\n\n"
          crew_members = CrewMemberFactory.crew_list

          crew_members.each do |member|
            if member.ship_number == 1
              member.ship_number = 0
            end
          end
        end
    end
  end

  def process; InterfaceFTL.process_loop; end
end

trainer = TrainerFTL.new
trainer.hook
trainer.activate
trainer.process