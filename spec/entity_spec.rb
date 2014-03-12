require 'spec_helper'

class FakeEntity
  include Whenua::Entity
end

describe Whenua::Entity do

  subject do
    FakeEntity.new
  end

  it 'responds to #model_name' do
    subject.respond_to?(:model_name).should be_true
  end

  describe "#created_at" do
    it "returns a Time object based on the created_at value" do
      time = Time.now
      subject.instance_variable_set(:@created_at, time)

      subject.created_at.to_s.should == time.to_s
      subject.created_at.instance_of?(Time).should be_true
    end
  end

  describe "#updated_at" do
    it "returns a Time object based on the updated_at value" do
      time = Time.now
      subject.instance_variable_set(:@updated_at, time)

      subject.updated_at.to_s.should == time.to_s
      subject.updated_at.instance_of?(Time).should be_true
    end
  end

  describe "#persisted?" do
    it "returns true if the entity already has an ID" do
      subject.instance_variable_set(:@id, 'afakeid')

      subject.persisted?.should be_true
    end

    it "returns false if the entity doesn't have an ID yet" do
      subject.persisted?.should be_false
    end
  end

  describe "#touch" do

    before(:each) do
      @time_now = Time.parse("Aug 23 1983")
      Time.stub!(:now).and_return(@time_now)
    end

    it "sets the created_at timestamp at now if it has not been set yet" do
      subject.touch
      subject.created_at.to_s.should == @time_now.to_s
    end

    it "sets doesn't change the created_at timestamp if it has been set already" do
      other_time = Time.parse("Aug 23 2013")
      subject.instance_variable_set(:@created_at, other_time)

      subject.touch
      subject.created_at.to_s.should == other_time.to_s
    end

    it "sets the updated_at timestamp at now" do
      subject.touch
      subject.updated_at.to_s.should == @time_now.to_s
    end
  end

  describe "#type" do
    it "returns the type of the entity" do
      subject.type.should == 'fake_entity'
    end
  end

  describe "#==" do

    let(:entity1) { FakeEntity.new }

    let(:entity2) { FakeEntity.new }

    it "returns true if both entities are identical" do
      entity1.instance_variable_set(:@id, 'anid')
      entity2.instance_variable_set(:@id, 'anid')

      (entity1 == entity2).should be_true
    end

    it "returns false if both entities have different ids" do
      entity1.instance_variable_set(:@id, 'anid')
      entity2.instance_variable_set(:@id, 'anotherid')

      (entity1 == entity2).should be_false
    end

    it "returns false if both entities have different types" do
      entity1.instance_variable_set(:@id, 'anid')
      entity2.instance_variable_set(:@id, 'anid')
      entity1.stub(:type).and_return('a_type')
      entity2.stub(:type).and_return('another_type')

      (entity1 == entity2).should be_false
    end
  end

end
