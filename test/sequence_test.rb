require 'test_helper'

describe Timed::Sequence do
  subject { ::Timed::Sequence }
  let(:item_klass) { ::Timed::Item }
  
  # Setup items so that item_a1 overlap with item_a2 exactly overlap_a amount
  let(:item_a1) { TestHelper.item 0...10, 10..20 }
  let(:item_a2) { TestHelper.item 0...10, 10..20 }
  
  let(:item_a) { ::Timed::Item.new 1..9 }
  let(:item_b) { ::Timed::Item.new 14..20 }

  let(:sequence) { subject.new << item_a << item_b }

  describe '#begin' do
    it 'returns 0 for empty sequences' do
      assert_equal 0, subject.new.begin
    end
    
    it 'returns the begin time of the first item' do
      assert_equal item_a.begin, sequence.begin
    end
  end
  
  describe '#end' do
    it 'returns 0 for empty sequences' do
      assert_equal 0, subject.new.end
    end
    
    it 'returns the end time of the last item' do
      assert_equal item_b.end, sequence.end
    end
  end

  describe '#length' do
    it 'returns 0 for empty sequences' do
      assert_equal 0, subject.new.length
    end
    
    it 'returns the time during which the sequence has items' do
      true_length = item_b.end - item_a.begin
      assert_equal true_length, sequence.length
    end
  end
  
  describe '#time' do
    it 'returns 0 for empty sequences' do
      assert_equal 0, subject.new.time
    end
    
    it 'returns the time covered by the items' do
      true_time = item_a.duration + item_b.duration
      assert_equal true_time, sequence.time
    end
  end
  
  describe '#intersections' do
    it 'returns an empty enumerator when there is no overlap'
    it 'returns an enumerator when not given a block' do
      #assert_kind_of Enumerator, sequence.intersections()
    end
  end
end
