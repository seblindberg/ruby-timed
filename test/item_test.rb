require 'test_helper'

describe Timed::Item do
  subject { ::Timed::Item }
  
  let(:range) do
    start_at = Random.rand 0.0..100.0
    duration = Random.rand 1.0..10.0
    end_at = start_at + duration
    start_at..end_at
  end
  
  let(:range_after) do
    offset = Random.rand 0.0..10.0
    duration = Random.rand 1.0..10.0
    start_at = range.end + offset
    end_at = start_at + duration
    start_at..end_at
  end
  
  let(:range_during) do
    start_at = Random.rand range.begin..(range.end - 0.01)
    end_at = Random.rand (range_after.begin + 0.01)..range_after.end
    start_at..end_at
  end
  
  let(:item) { subject.new range }
  let(:item_during) { subject.new range_during }
  let(:item_after) { subject.new range_after }
  
  describe '.new' do
    it 'raises an exception with no argument' do
      assert_raises(ArgumentError) { subject.new }
    end
    
    it 'requires an argument that respond to both #begin and #end' do
      arg = Minitest::Mock.new
      arg.expect :begin, 0
      arg.expect :end, 9
      subject.new arg
      
      arg.verify
    end
    
    it 'requires the timespan to begin before it ends' do
      assert_raises(ArgumentError) { subject.new 9..0 }
    end
    
    it 'requires #begin and #end to return numerics' do
      arg = Minitest::Mock.new
      arg.expect :begin, 'a'
      arg.expect :end, 9
      
      assert_raises(TypeError) { subject.new arg }
      
      arg.expect :begin, 0
      arg.expect :end, 'z'
      
      assert_raises(TypeError) { subject.new arg }
    end
  end
  
  describe '#begin' do
    it 'returns the start time' do
      assert_equal range.begin, item.begin
    end
  end
  
  describe '#end' do
    it 'returns the end time' do
      assert_equal range.end, item.end
    end
  end
  
  describe '#duration' do
    it 'returns the difference between the end and start times' do
      assert_equal (range.end - range.begin), item.duration
    end
  end
  
  describe '#before?' do
    it 'returns true if the item ends before the other' do
      assert item.before?(item_after)
    end
    
    it 'returns false if the item does not end before the other' do
      refute item.before?(item_during)
    end
    
    it 'accepts any object that responds to #begin' do
      obj = Minitest::Mock.new
      obj.expect :begin, item.end
      assert item.before?(obj)
      obj.verify
    end
  end
  
  describe '#after?' do
    it 'returns true if the item begins after the other ends' do
      assert item_after.after?(item)
    end
    
    it 'returns false if the item does not begin after the other ends' do
      refute item_after.after?(item_during)
    end
    
    it 'accepts any object that responds to #end' do
      obj = Minitest::Mock.new
      obj.expect :end, item.begin
      assert item.after?(obj)
      obj.verify
    end
  end
  
  describe '#during?' do
    it 'returns true when the items overlap' do
      assert item.during?(item_during)
    end
    
    it 'returns false when the items do not overlap' do
      refute item.during?(item_after)
    end
    
    it 'accepts any object that responds to #begin and #end' do
      assert item.during?(range_during)
      refute item.during?(range_after)
    end
  end
  
  describe '#append' do
    it 'raises an error it the items are not sequential' do
      assert_raises { item_after.append item }
    end
      
    it 'raises an error it the items overlap' do
      assert_raises { item.append item_during }
    end
    
    it 'accepts correctly ordered items' do
      item.append item_after
      assert_same item_after, item.next
    end
    
    it 'accepts objects responding to #begin and #end' do
      item.append range_after
      
      assert_kind_of subject, item.next
      assert_equal range_after.begin, item.next.begin
      assert_equal range_after.end, item.next.end
    end
  end
  
  describe '#prepend' do
    it 'raises an error it the items are not sequential' do
      assert_raises { item.prepend item_after }
    end

    it 'raises an error it the items overlap' do
      assert_raises { item_during.prepend item }
    end

    it 'accepts correctly ordered items' do
      item_after.prepend item
      assert_same item, item_after.previous
    end
    
    it 'accepts objects responding to #begin and #end' do
      item_after.prepend range
      
      assert_kind_of subject, item_after.prev
      assert_equal range.begin, item_after.prev.begin
      assert_equal range.end, item_after.prev.end
    end
  end
  
  describe '#inspect' do
    it 'includes the class name' do
      refute_nil item.inspect[item.class.name]
    end
    
    it 'includes the start time' do
      start_at = format '%.2f', range.begin
      refute_nil item.inspect[start_at]
    end
    
    it 'includes the end time' do
      end_at = format '%.2f', range.end
      refute_nil item.inspect[end_at]
    end
  end
end