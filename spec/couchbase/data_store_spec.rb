require 'spec_helper_couchbase'

describe Whenua::Couchbase::DataStore do

  context 'when initialized with a correct configuration' do

    subject do
      Whenua::Couchbase::DataStore.new(
        host: 'localhost',
        port: 8091,
        bucket: 'whenua-test'
      )
    end


    describe '#client' do
      it 'returns a valid couchbase bucket connexion' do
        subject.client.instance_of?(Couchbase::Bucket).should be_true
        subject.client.connected?.should be_true
      end
    end


    describe '#save' do
      it 'persists a new document to the bucket' do
        key = subject.save(value: { topic: 'The answer', content: 'We dunno !' })

        doc = subject.client.get(key)

        doc['topic'].should == 'The answer'
      end

      it 'updates a existing document in the bucket' do
        key = subject.save(value: { topic: 'The question?', content: 'We knew !' })
        subject.save(key: key, value: { topic: 'The answer', content: 'We dunno !' })

        doc = subject.client.get(key)

        doc['topic'].should == 'The answer'
      end
    end


    describe '#delete' do
      it 'removes an existing document from the bucket' do
        subject.client.quiet = true # We don't need to handle the exception for this test

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
        result["fake"].should == 'Really?'
      end
    end

    describe '#fetch' do
      it 'executes the index method whose name is passed in parameter and returns the result' do
        result = subject.fetch(:fake_index, :tests)
      end

      it 'raises an IndexMissingError exception if no index exist for the given name' do
        expect { subject.fetch(:non_existing_index, :tests) }.to raise_error(Whenua::IndexMissingError)
      end
    end

  end

end
