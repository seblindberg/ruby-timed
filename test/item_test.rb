require 'test_helper'

describe Timed::Item do
  subject { ::Timed::Item }
  
  let(:range) { TestHelper.range 0.0..10.0, 11.0..20.0 }
  let(:range_during) {
    TestHelper.range 10.0...range.end, range_after.begin..30.0 }
  let(:range_after) { TestHelper.range 20.0..30.0, 31.0..40.0 }
  
  let(:item) { subject.new range }
  let(:item_during) { subject.new range_during }
  let(:item_after) { subject.new range_after }
  let(:item_cover) {
    TestHelper.item 0...item_during.begin, item_during.end..40.0 }
  
  describe '.new' do
    it 'raises an exception with no argument' do
      assert_raises(ArgumentError) { subject.new }
    end
    
    it 'requires an argument that respond to both #begin and #end' do
      arg = Minitest::Mock.new
      arg.expect :begin, 0
      arg.expect :end, 9
      
      item = subject.new arg
      
      arg.verify
      assert_equal 0, item.begin
      assert_equal 9, item.end
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
    
    it 'also accepts a second argument' do
      item = subject.new 0, 9
      
      assert_equal 0, item.begin
      assert_equal 9, item.end
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
  
  describe '#==' do
    it 'returns true if the items share begin and end times' do
      assert_equal item, item
      assert_equal item, range
    end
    
    it 'returns false when the begin and end times are different' do
      refute_equal item, item_after
    end
      
    it 'returns false for objects without #begin' do
      no_begin = Minitest::Mock.new
      no_begin.expect(:end, 0)
      refute_operator item, :==, no_begin
    end
    
    it 'returns false for objects without #end' do
      no_end = Minitest::Mock.new
      no_end.expect(:begin, 0)
      refute_operator item, :==, no_end
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
  
  describe '#intersect' do
    it 'return nil when the items does not intersect' do
      assert_nil item.intersect(item_after)
    end
    
    it 'returns a new Item that cover the common time between the two' do
      item_a = item.intersect(item_during)
      item_b = item_during.intersect(item)
      item_c = item_during.intersect(item_cover)
      
      assert_equal item_during.begin, item_a.begin
      assert_equal item.end, item_a.end
      
      assert_equal item_during.begin, item_b.begin
      assert_equal item.end, item_b.end
      
      assert_equal item_during.begin, item_c.begin
      assert_equal item_during.end, item_c.end
    end
    
    it 'is aliased to #&' do
      assert_equal item.method(:intersect), item.method(:&)
    end
  end
  
  describe '#append' do
    it 'accepts correctly ordered items' do
      item.append item_after
      assert_same item_after, item.next
    end
    
    it 'raises an error it the items are not sequential' do
      assert_raises { item_after.append item }
    end
      
    it 'raises an error it the items overlap' do
      item_a = subject.new 0, 10
      item_b = subject.new 20, 30
      item_a.append item_b
      
      assert_raises { item_a.append(subject.new 5, 15) }
      assert_raises { item_a.append(subject.new 15, 25) }
    end
    
    it 'accepts objects responding to #begin and #end' do
      item.append range_after
      
      assert_kind_of subject, item.next
      assert_equal range_after.begin, item.next.begin
      assert_equal range_after.end, item.next.end
    end
  end
  
  describe '#prepend' do
    it 'accepts correctly ordered items' do
      item_after.prepend item
      assert_same item, item_after.previous
    end
      
    it 'raises an error it the items are not sequential' do
      assert_raises { item.prepend item_after }
    end

    it 'raises an error it the items overlap' do
      item_a = subject.new 0, 10
      item_b = subject.new 20, 30
      item_a.append item_b
      
      assert_raises { item_b.prepend(subject.new 15, 25) }
      assert_raises { item_b.prepend(subject.new 5, 15) }
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