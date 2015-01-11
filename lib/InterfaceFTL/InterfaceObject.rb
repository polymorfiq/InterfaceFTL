require 'OSXMemory'

module InterfaceFTL
  class InterfaceObject < OSXMemory::InterfaceObject
    def instance; InterfaceFTL.instance; end
    def self.instance; InterfaceFTL.instance; end

    def initialize(base_offset)
      @base_offset = base_offset
    end
  end
end