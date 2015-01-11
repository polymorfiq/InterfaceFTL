require_relative "InterfaceObject"

module InterfaceFTL
  class CrewMember < InterfaceObject
    property :name,             :string,  0x2a0
    property :owner_ship,       :int,     0x8
    property :boarded_ship,     :int,     0x194
    property :room_number,      :int,     0x1e4
    property :room_x,           :int,     0xb4
    property :room_y,           :int,     0xb8
    property :ship_address,     :address, 0x1f8
    property :position_x,       :float,   0x18
    property :position_y,       :float,   0X1C
    property :world_position_x, :int,     0xbc
    property :world_position_y, :int,     0xc0
    property :species,          :string,  0x220
    property :health,           :float,   0x38
    property :mind_controlled,  :bool,    0x4f1

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

    def is_intruding?; self.boarded_ship_number == self.ship_number; end
    def provides_vision?; (self.owner_ship == 0 || self.mind_controlled == 1 ? 1 : 0); end
  end
end