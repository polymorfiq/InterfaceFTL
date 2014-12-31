require 'ostruct'
require_relative "InterfaceObject"

module InterfaceFTL
  class CrewMember < InterfaceObject

    module Species
      HUMAN = 0x10022d174
      ENG = 0x10022bf9d
      GHOST = 0x10023f083
      ENERGY = 0x10023f074
      ROCK = 0x10024333c
      SLUG = 0x10023f07b
      MANTIS = 0x10023f3a6
      ANAEROBIC = 0x10023f065
    end

    def initialize(base_offset)
      super()
      self.schema[:base][:offset] = base_offset
    end

    def species; read_string(self.species_address, 20); end

    def position
      OpenStruct.new({x: position_x, y: position_y})
    end

    def is_intruding?; self.boarded_ship_number == self.ship_number; end

    private

    define_schema({
      base: {type: :base, offset: 0x0},
      boarded_ship_number: {type: :int, offset: 0x8},
      position_x: {type: :int, offset: 0x18},
      position_y: {type: :int, offset: 0X1C},
      ship_number: {type: :int, offset: 0x194},
      species_address: {type: :address, offset: 0x220}
    })

  end
end