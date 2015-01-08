require 'ostruct'
require_relative "InterfaceObject"

module InterfaceFTL
  class CrewMember < InterfaceObject

    module Species
      HUMAN = "human"
      ENGI = "engi"
      GHOST = "ghost"
      ENERGY = "energy"
      ROCK = "rock"
      SLUG = "slug"
      MANTIS = "mantis"
      ANAEROBIC = "anaerobic"
    end

    def initialize(base_offset)
      super()
      self.schema[:base][:offset] = base_offset
    end

    def position
      OpenStruct.new({x: position_x, y: position_y})
    end

    def is_intruding?; self.boarded_ship_number == self.ship_number; end

    private

    define_schema({
      base: {type: :base, offset: 0x0},
      name: {type: :string, offset: 0x2a0},
      boarded_ship_number: {type: :int, offset: 0x8},
      position_x: {type: :int, offset: 0x18},
      position_y: {type: :int, offset: 0X1C},
      ship_number: {type: :int, offset: 0x194},
      species: {type: :string, offset: 0x220},
      health: {type: :float, offset: 0x38}
    })

  end
end