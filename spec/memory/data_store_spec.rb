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

describe Whenua::Memory::DataStore do

  subject do
    FakeDataStore.new
  end

  describe '#save' do
    it 'persists a new document to the bucket' do
      key = subject.save(value: { topic: 'The answer', content: 'We dunno !' })

      doc = subject.client.get(key)

      doc[:data][:topic].should == 'The answer'
    end

    it 'updates a existing document in the bucket' do
      key = subject.save(value: { topic: 'The question?', content: 'We knew !' })
      subject.save(key: key, value: { topic: 'The answer', content: 'We dunno !' })

      doc = subject.client.get(key)

      doc[:data][:topic].should == 'The answer'
    end
  end


  describe '#delete' do
    it 'removes an existing document from the bucket' do
      key = subject.save(value: { fake: 'Really?' })

      subject.client.get(key).should_not == nil
      subject.delete(key)
      subject.client.get(key).should == nil
    end
  end

  describe '#get' do
    it 'returns the document corresponding to the provided ID' do
      key = subject.save(value: { fake: 'Really?' })
      result = subject.get(key)
      result[:data][:fake].should == 'Really?'
    end
  end

  describe '#fetch' do
    it 'executes the index method whose name is passed in parameter an returns the result' do
      result = subject.fetch(:fake_index)
      result.length.should == 2
    end

    it 'raises an IndexMissingError exception if no index exist for the given name' do
      expect { subject.fetch(:non_existing_index) }.to raise_error(Whenua::IndexMissingError)
    end
  end

end
