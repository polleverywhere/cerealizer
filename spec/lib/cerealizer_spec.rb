require 'spec_helper'

describe Cerealizer do

  # Anonomous classes we use to test cerealizer
  let(:cereal_klass) { Struct.new(:name, :sugar_content, :private_notes, :owner_id, :prize, :id) }
  let(:user_klass) { Struct.new(:name, :role, :id) }
  let(:serializer_klass) do
    # Weird eh? Its an anonymous class. Don't want to litter the Global namespace with
    # constants that don't make sense.
    Class.new Cerealizer::Base do
      key :name
      key :private_notes
      key :sugar_content
      key :prize do
        reader {|val| val.capitalize }
        writer {|val| val.downcase }
      end
    end
  end

  # We're gonna use these instances for the test cases.
  let(:brad){ user_klass.new('Brad Gessler', :admin, 1) }
  let(:joe){ user_klass.new('Joe Shmoe', :anon, 2) }
  let(:cheerios){ cereal_klass.new('Cheerios', '1 gram', 'Tastes like cardboard', brad.id, 1) }
  let(:cheerios_serializer){ serializer_klass.new(cheerios, brad) }

  describe "#read_keys" do
    it "should serialize keys" do
      cheerios_serializer.read_keys.keys.should include(:name, :private_notes, :sugar_content)
    end

    it "should serialize values" do
      cheerios_serializer.read_keys.values.should include('Cheerios', '1 gram', 'Tastes like cardboard')
    end
  end

  describe ".read_keys" do
    it "should serialize array of objects" do
      array = serializer_klass.read_keys [cheerios, cheerios], brad
      array.each do |hash|
        hash.keys.should include(*serializer_klass.keys.map(&:name))
      end
    end
  end

  describe "#write_keys" do
    it "should update object attributes" do
      cheerios_serializer.write_keys(:name => 'Captain Crunch').object.name.should == 'Captain Crunch'
    end
  end

  describe ".href" do
    let(:serializer_klass) do
      Class.new Cerealizer::Base do
        key :id

        href "/users/:owner_id"
        href "/fruits/:id"
      end
    end

    it "should read #owner_href key" do
      cheerios_serializer.read_keys[:owner_href].should == "/users/#{brad.id}"
    end

    it "should write #owner_href key" do
      cheerios_serializer.write_keys(:owner_href => "/users/#{joe.id}").object.owner_id.should == joe.id.to_s
    end

    it "should read #href key" do
      cheerios_serializer.read_keys[:href].should == "/fruits/#{cheerios.id}"
    end

    it "should write #href key" do
      cheerios_serializer.write_keys(:href => "/fruits/99").object.id.should == '99'
    end
  end
end

describe Cerealizer::PathRouter do
  let(:href) { Cerealizer::PathRouter.new("/users/:owner_id") }

  it "should recognize uri" do
    href.recognize("/users/12")[:owner_id].should == '12'
  end

  describe "#generate" do
    it "should generate valid uri" do
      href.generate(:owner_id => 1212).should == '/users/1212'
    end
  end
end
