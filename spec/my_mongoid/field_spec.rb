require 'spec_helper'

class User
  include MyMongoid::Document
  field :name
  field :address, :as => 'addr'
end

describe MyMongoid::Field do
  let(:attributes) {
    {'name' => 'kojima', 'address' => 'Tokyo'}
  }

  let(:user) {
    User.new(attributes)
  }

  it 'is a module' do
    expect(MyMongoid::Field).to be_a(Module)
  end

  it "declares getter for a field" do
    expect(user).to respond_to(:name)
    expect(user.name).to eq(attributes["name"])
  end

  it "declares setter for a field" do
    expect(user).to respond_to(:address=)
    user.address = 'osaka'
    expect(user.address).to eq('osaka')
    expect(user.read_attribute("address")).to eq('osaka')
  end

  context ".fields" do
    let(:fields) {
      User.fields
    }

    it "maintains a map fields objects" do
      expect(fields).to be_a(Hash)
      expect(fields.keys).to include(*%w(name address))
    end

    it "returns a string for Field#name" do
      field = fields["name"]
      expect(field).to be_a(MyMongoid::Field)
      expect(field.name).to eq("name")
    end
  end

  it "raises MyMongoid::DuplicateFieldError if field is declared twice" do
    expect {
      User.module_eval do
        field :name
      end
    }.to raise_error(MyMongoid::DuplicateFieldError)
  end

  it "automatically declares the '_id' field"  do
    expect(User.fields.keys).to include("_id")
  end
end
