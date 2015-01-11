require_relative "InterfaceObject"
require_relative "CrewMember"

module InterfaceFTL
  class CrewMemberFactory < InterfaceObject
    base_offset 0x1002c5280

    static_property :player_crew_count, :int,     0x0
    static_property :enemy_crew_count,  :int,     0x4
    static_property :crew_list_address, :address, 0x10

    def self.crew_list
      crew = []

      for i in 0...(player_crew_count + enemy_crew_count)
        address = OSXMemory::InterfaceProperty.read_with_type(self.instance, :address, self.crew_list_address + (i * 0x8))
        crew << CrewMember.new(address)
      end

      crew
    end
  end
end