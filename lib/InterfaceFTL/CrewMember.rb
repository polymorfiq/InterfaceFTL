require 'ostruct'
require_relative "InterfaceObject"

module InterfaceFTL
  class CrewMember < InterfaceObject

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
      boarded_ship_number: {type: :int, offset: 0x8},
      position_x: {type: :int, offset: 0x18},
      position_y: {type: :int, offset: 0X1C},
      ship_number: {type: :int, offset: 0x194}
    })

  end
end