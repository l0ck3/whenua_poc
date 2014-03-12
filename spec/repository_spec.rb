require 'spec_helper'

class FakeDataStore < Whenua::Memory::DataStore
private
  def fake_index
    [
      {
        key: 'key1',
        value: {name: 'row1'}
      },
      {
        key: 'key2',
        value: {name: 'row2'}
      },
    ]
  end
end

class FakeEntity
  include Whenua::Entity

  attribute :name, String
end

class FakeEntityRepository
  include Whenua::Repository

  index :fake_index
end

describe Whenua::Repository do

  context 'when initialized with an active datastore' do

    let(:data_store) { FakeDataStore.new }

    let(:fake_key) { key = 'afakekey' }

    let(:fake_entity) do
      entity = FakeEntity.new
      entity.instance_variable_set(:@id, fake_key)
      entity
    end

    before(:each) do
      doc = {name: 'Fake One!'}
      data_store.save(key: fake_key, value: doc)
    end

    subject do
      FakeEntityRepository.new(data_store)
    end

    it 'responds to defined index methods' do
      subject.respond_to?(:fake_index).should be_true
    end

    it 'provides data access via defined index methods' do
      subject.fake_index
    end

    describe '#delete' do
      it 'deletes the provided record from the data store' do
        subject.delete(fake_entity)

        data_store.get(fake_key).should be_nil
      end
    end

    describe '#find_by_id' do
      it 'returns the entity associated to the given id if it exists' do
        result = subject.find_by_id(fake_key)

        result.instance_of?(FakeEntity).should be_true
        result.id.should == fake_key
        result.name.should == 'Fake One!'
      end

      it 'returns false if no entity exists for the given id' do
        result = subject.find_by_id('Idontexist')
        result.should be_false
      end
    end

    describe '#save' do
      it 'persists a new entity to the data store' do
        entity = FakeEntity.new(name: 'New Entity')
        entity = subject.save(entity)
        found_entity = subject.find_by_id(entity.id)

        found_entity.should == entity
      end

      it 'updates an existing entity to the data store' do
        entity = subject.find_by_id(fake_key)
        entity.name.should == 'Fake One!'
        entity.name = 'New Name'

        subject.save(entity)

        entity = subject.find_by_id(fake_key)
        entity.name.should == 'New Name'
      end
    end

  end

end
