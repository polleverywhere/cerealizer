require "cerealizer/version"
require 'uri'
require 'set'

# A quick and dirty class for recognizing and generating URL paths.
class PathRouter
  PATH_DELIMITER = '/'
  VARIABLE_REGEXP = /^\:(.+)/

  attr_reader :uri

  def initialize(uri)
    @uri = URI.parse(uri)
  end

  # Return the segments out of this thing that are 
  def recognize(uri)
    if captures = regexp.match(URI.parse(uri).path).captures
      Hash[variables.zip captures]
    end
  end

  # Generate an URL based on a hash of variables
  def generate(vars={})
    segments.map{|s| s =~ VARIABLE_REGEXP ? vars[$1.to_sym] : s }.join(PATH_DELIMITER)
  end

  # A Set of the variables in the URL.
  def variables
    @variables ||= Set.new(segments.grep(VARIABLE_REGEXP){ $1 }.map(&:to_sym))
  end

private
  # Convert the path into a Regexp that we can use to recognize shiz.
  def regexp
    @regexp ||= compile_regexp
  end

  # Get all of the segments in the URL.
  def segments
    @segments ||= uri.path.split(PATH_DELIMITER)
  end

  # Comples a regexp that's used to capture the URL and its segments.
  def compile_regexp
    Regexp.new("^#{segments.map{ |s| s =~ VARIABLE_REGEXP ? '(.+)' : s }.join('\/')}$")
  end
end

module Cerealizer
  # Encapsulates information about keys.
  class Key
    attr_reader :name

    def initialize(name, &block)
      @name = name
      self
    end
  end

  # Configure a serialize keys and deal with marshaling to and from JSON.
  class Base
    attr_reader :object, :scope

    def initialize(object, scope)
      @object, @scope = object, scope
      # K, back to your regularly scheduled programming...
      self
    end

    # Call methods on the object that's being presented and create a flat 
    # hash for these mofos.
    def read_keys
      self.class.keys.inject Hash.new do |hash, key|
        hash[key.name] = proxy_reader(key.name) if readable?(key.name)
        hash
      end
    end

    # Update the attrs on zie model.
    def write_keys(attrs)
      attrs.each { |key, value| proxy_writer(key, value) if writeable?(key) }
      self
    end

    # Registers a key with the class.
    def self.key(key)
      keys.push Key.new(key)
    end

    # Keys that are registered with the class.
    def self.keys
      @keys ||= []
    end

    # Read the keys on each object in a collection of objects.
    def self.read_keys(objects, user)
      objects.map { |object| self.new(object,user).read_keys }
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