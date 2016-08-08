require 'test_helper'

describe Timed::Sequence do
  subject { ::Timed::Sequence }
  let(:item_klass) { ::Timed::Item }
  
  let(:item_a) { TestHelper.item 0...10, 10..20 }
  let(:item_b) { TestHelper.item 20...30, 30..40 }

  let(:sequence) { subject.new << item_a << item_b }

  # Setup items so that item_a1 overlap with item_a2
  let(:item_a1) { TestHelper.item 0...10, 10..20 }
  let(:item_a2) { TestHelper.item 0...10, 10..20 }
  let(:item_b1) { TestHelper.item 20...30, 30..40 }
  let(:item_b2) { TestHelper.item 20...30, 30..40 }
  
  let(:intersection_a) { (item_a1 & item_a2) }
  let(:intersection_b) { (item_b1 & item_b2) }
  
  let(:sequence_1) { subject.new << item_a1 << item_b1 }
  let(:sequence_2) { subject.new << item_a2 << item_b2 }

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
    it 'returns an enumerator when not given a block' do
      assert_kind_of Enumerator, sequence_1.intersections(sequence_2)
    end
    
    it 'returns an empty enumerator when there is no overlap' do
      sequence_1 = subject.new << item_a
      sequence_2 = subject.new << item_b
      
      sequence_1.intersections(sequence_2) { assert false }
    end
    
    it 'yields the two intersections' do
      enum = sequence_1.intersections sequence_2
      
      b1, e1 = enum.next
      assert_equal intersection_a.begin, b1
      assert_equal intersection_a.end, e1
      
      b2, e2 = enum.next
      assert_equal intersection_b.begin, b2
      assert_equal intersection_b.end, e2
      
      assert_raises(StopIteration) { enum.next }
    end
  end
  
  describe '#intersect' do
    
  end
  
  describe '#intersect_time' do
    it 'returns 0 when there is no intersection' do
      
    end
    
    it 'returns the total time of the intersections' do
      true_time = intersection_a.duration + intersection_b.duration
      assert_equal true_time, sequence_1.intersect_time(sequence_2)
    end
  end
end
