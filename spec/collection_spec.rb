require 'spec_helper'

describe Whenua::Collection do

  let(:array) { %w(1 2 3 4 5 6 7 8 9 10) }

  subject do
    Whenua::Collection.new(3, 3, array)
  end

  describe '#array' do
    it 'returns the array managed by the collection' do
      subject.array.instance_of?(Array).should be_true
      subject.array.length.should == 10
    end
  end

  describe '#current_page' do
    it 'returns the current page' do
      subject.current_page.should == 3
    end
  end

  describe '#skip_value' do
    it 'returns the number of records to skip to match the current page' do
      subject.skip_value.should == 6
    end
  end

  describe '#total_pages' do
    it 'returns the total number of pages' do
      subject.total_pages.should == 4
    end
  end

  describe '#limit_value' do
    it 'returns the limit value' do
      subject.limit_value.should == 3
    end
  end

  describe '#total_rows' do
    it 'returns the total number of rows' do
      subject.total_rows.should == 10
    end
  end

end
