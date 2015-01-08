
module InterfaceFTL
  module InterfaceObjectMethods
    def game_instance; InterfaceFTL.instance; end

    def read_signed_int(addr, size = 4)
      game_instance.read(addr, size).unpack('l').first
    end

    def read_unsigned_int(addr, size = 4)
      game_instance.read(addr, size).unpack('L').first
    end

    def read_float(addr, size = 8)
      game_instance.read(addr, size).unpack("F").first
    end

    def read_address_from(addr, size = 8)
      game_instance.read(addr, size).unpack('Q').first
    end

    def read_string(addr, max_size = 100)
      game_instance.read(addr, max_size).unpack("Z#{max_size}").first
    end

    def allocate_string(string)
    end
  end

  class InterfaceObjectSchema
    extend InterfaceObjectMethods
    include InterfaceObjectMethods

    attr_accessor :schema
    @schema = {}

    def initialize(schema); @schema = schema; end
    def include?(key); @schema.include?(key); end

    def set(property, value)
      packer = nil
      should_pause = false
      write_address = @schema[:base][:offset] + property[:offset]
      property_type = property[:type]

      if property_type == :string
        string_data = [value].pack('Z*')
        new_string_address = game_instance.alloc(string_data.size)
        game_instance.write(new_string_address, string_data)
        value = new_string_address
        property_type = :address
      end

      case property_type
      when :uint
        packer = 'L'
      when :int
        packer = 'l'
      when :float
        packer = 'F'
      when :address
        should_pause = true
        packer = 'Q'
      when :string
        should_pause = true
        packer = 'Q'
      when :base
        return
      end

      game_instance.suspend if should_pause
      game_instance.write(write_address, [value].pack(packer))
      game_instance.resume if should_pause
    end

    def get(property)
      packer = nil

      case property[:type]
      when :uint
        read_unsigned_int(@schema[:base][:offset] + property[:offset])
      when :int
        read_signed_int(@schema[:base][:offset] + property[:offset])
      when :float
        read_float(@schema[:base][:offset] + property[:offset])
      when :address
        read_address_from(@schema[:base][:offset] + property[:offset])
      when :string
        read_string(read_address_from(@schema[:base][:offset] + property[:offset]))
      when :base
        return
      end
    end

    def parse(method_name, *arguments, &block)
      parsed_name = method_name.to_s.gsub('=', '').to_sym
      property = @schema[parsed_name]

      if method_name.to_s =~ /^(.*)=$/
        set(property, *arguments, &block)
      else
        get(property, *arguments, &block)
      end
    end

    def schema_dup; Marshal.load(Marshal.dump(self.schema)); end

  end

  class InterfaceObject
    extend InterfaceObjectMethods
    include InterfaceObjectMethods

    @@instance_schema = InterfaceObjectSchema.new({})
    @static_schema = InterfaceObjectSchema.new({})

    def initialize
      @schema = InterfaceObjectSchema.new(@@instance_schema.schema_dup)
    end

    def self.define_schema(schema)
      @@instance_schema = InterfaceObjectSchema.new schema
    end

    def self.define_static_schema(schema)
      @static_schema = InterfaceObjectSchema.new schema
    end

    def schema; @schema.schema; end
    def self.schema; @static_schema.schema; end


    def method_missing(method_name, *arguments, &block)
      parsed_name = method_name.to_s.gsub('=', '').to_sym
      super and return unless @schema.include? parsed_name
      @schema.parse(method_name, *arguments, &block)
    end

    def self.method_missing(method_name, *arguments, &block)
      parsed_name = method_name.to_s.gsub('=', '').to_sym
      super and return unless @static_schema.include? parsed_name
      @static_schema.parse(method_name, *arguments, &block)
    end

    def respond_to?(method_name, include_private = false)
      @schema.include? method_name || super
    end

    def self.respond_to?(method_name, include_private = false)
      @static_schema.include? method_name || super
    end
  end
end