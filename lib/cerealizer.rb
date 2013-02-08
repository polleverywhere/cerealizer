require "cerealizer/version"

module Cerealizer
  # Encapsulates information about keys.
  class Key
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  # Configure a serialize keys and deal with marshaling to and from JSON.
  class Base
    attr_reader :object, :scope

    def initialize(object, scope)
      @object, @scope = object, scope
      self
    end

    def self.key(key)
      keys.push Key.new(key)
    end

    def self.keys
      @keys ||= []
    end

    # Call methods on the object that's being presented and create a flat 
    # hash for these mofos.
    def serializable_hash
      self.class.keys.inject Hash.new do |hash, key|
        hash[key.name] = proxy_reader(key.name) if readable?(key.name)
        hash
      end
    end

    # Update the attrs on zie model.
    def update_attributes(attrs={})
      attrs.each { |key, value| proxy_writer(key, value) if writeable?(key.name) }
      self
    end

  private
    # TODO - Should the default be writable?
    def writeable?(key)
      meth = "has_writable_#{key}?"
      self.respond_to?(meth) ? self.send(meth) : true
    end

    # TODO - Should the default be writable?
    def readable?(key)
      meth = "has_readable_#{key}?"
      self.respond_to?(meth) ? self.send(meth) : true
    end

    # Look for methods locally that we want to use to proxy data between
    # the object and its JSON format.
    def proxy_reader(key)
      if self.respond_to? key
        self.send(key)
      else
        object.send(key)
      end
    end

    # Proxy the writer to zie object.
    def proxy_writer(key, *args)
      meth = "#{key}="
      if self.respond_to? meth
        self.send(meth, *args)
      else
        object.send(meth, *args)
      end
    end
  end
end