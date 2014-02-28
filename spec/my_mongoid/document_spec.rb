require 'spec_helper'

class Event
  include MyMongoid::Document
  field :name
  field :address, :as => 'addr'
  field :number
  def number=(num)
    self.attributes["number"] = num + 1
  end
end

describe MyMongoid::Document do
  it 'is a module' do
    expect(MyMongoid::Document).to be_a(Module)
  end

  let(:attributes) {
    {'name' => 'my mongoid', 'address' => 'Tokyo'}
  }

  let(:event) {
    Event.new(attributes)
  }

  describe '.new' do
    it 'can instantiate a model with attributes' do
      expect(event).to be_an(Event)
    end

    it 'throws an error if attributes it not a Hash' do
      expect {
        Event.new(100)
      }.to raise_error(ArgumentError)
    end

    it 'can read the attributes of model' do
      expect(event.attributes).to eq(attributes)
    end
  end

  describe '#read_attribute' do
    it 'can get an attribute with #read_attribute' do
      expect(event.read_attribute('name')).to eq('my mongoid')
    end
  end

  describe '#write_attribute' do
    it 'can set an attribute with #write_attribute' do
      event.write_attribute('name', 'mongoid')
      expect(event.read_attribute('name')).to eq("mongoid")
    end
  end

  describe '#process_attributes' do
    it "use field setters for mass-assignment" do
      event.process_attributes :number => 10
      expect(event.number).to eq(11)
    end

    it "raise MyMongoid::UnknownAttributeError if the attributes Hash contains undeclared fields." do
      expect {
        event.process_attributes :unkonwn => 10
      }.to raise_error(MyMongoid::UnknownAttributeError)
    end

    it "aliases #process_attributes as #attribute=" do
      event.attributes = {:number => 10}
      expect(event.number).to eq(11)
    end

    it "uses #process_attributes for #initialize" do
      event = Event.new({:number => 10})
      expect(event.number).to eq(11)
    end
  end

  describe '#new_record?' do
    it 'is a new record initially' do
      expect(event).to be_new_record
    end
  end
end
