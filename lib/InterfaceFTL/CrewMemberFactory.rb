require_relative "InterfaceObject"
require_relative "CrewMember"

module InterfaceFTL
  class CrewMemberFactory < InterfaceObject

    def self.crew_list
      crew = []

      for i in 0...(player_crew_count + enemy_crew_count)
        crew << CrewMember.new(read_address_from(self.crew_list_address + (i * 0x8)))
      end

      crew
    end

    private

    BASE_OFFSET = 0x1002c5280

    define_static_schema({
      base: {type: :base, offset: BASE_OFFSET},
      player_crew_count: {type: :int, offset: 0x0},
      enemy_crew_count: {type: :int, offset: 0x4},
      crew_list_address: {type: :address, offset: 0x10}
    })

  end
end