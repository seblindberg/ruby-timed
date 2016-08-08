require 'test_helper'

class Moment
  include Timed::Moment
  attr_accessor :begin, :end
  
  def initialize range
    @begin = range.begin
    @end = range.end
  end
end

describe Timed::Moment do
  subject { ::Moment }

  let(:range) { TestHelper.range 0.0..10.0, 11.0..20.0 }
  let(:range_during) {
    TestHelper.range 10.0...range.end, range_after.begin..30.0 }
  let(:range_after) { TestHelper.range 20.0..30.0, 31.0..40.0 }
  let(:range_cover) {
    TestHelper.moment 0...range_during.begin, range_during.end..40.0 }

  let(:moment) { subject.new range }
  let(:moment_during) { subject.new range_during }
  let(:moment_after) { subject.new range_after }
  let(:moment_cover) { subject.new range_cover }

  describe '#begin' do
    it 'returns the start time' do
      assert_equal range.begin, moment.begin
    end
  end

  describe '#end' do
    it 'returns the end time' do
      assert_equal range.end, moment.end
    end
  end

  describe '#duration' do
    it 'returns the difference between the end and start times' do
      assert_equal (range.end - range.begin), moment.duration
    end
  end

  describe '#==' do
    it 'returns true if the moments share begin and end times' do
      assert_equal moment, moment
      assert_equal moment, range
    end

    it 'returns false when the begin and end times are different' do
      refute_equal moment, moment_after
    end

    it 'returns false for objects without #begin' do
      no_begin = Minitest::Mock.new
      no_begin.expect(:end, 0)
      refute_operator moment, :==, no_begin
    end

    it 'returns false for objects without #end' do
      no_end = Minitest::Mock.new
      no_end.expect(:begin, 0)
      refute_operator moment, :==, no_end
    end
  end

  describe '#before?' do
    it 'returns true if the moment ends before the other' do
      assert moment.before?(moment_after)
    end

    it 'returns false if the moment does not end before the other' do
      refute moment.before?(moment_during)
    end

    it 'accepts any object that responds to #begin' do
      obj = Minitest::Mock.new
      obj.expect :begin, moment.end
      assert moment.before?(obj)
      obj.verify
    end
  end

  describe '#after?' do
    it 'returns true if the moment begins after the other ends' do
      assert moment_after.after?(moment)
    end

    it 'returns false if the moment does not begin after the other ends' do
      refute moment_after.after?(moment_during)
    end

    it 'accepts any object that responds to #end' do
      obj = Minitest::Mock.new
      obj.expect :end, moment.begin
      assert moment.after?(obj)
      obj.verify
    end
  end

  describe '#during?' do
    it 'returns true when the moments overlap' do
      assert moment.during?(moment_during)
    end

    it 'returns false when the moments do not overlap' do
      refute moment.during?(moment_after)
    end

    it 'accepts any object that responds to #begin and #end' do
      assert moment.during?(range_during)
      refute moment.during?(range_after)
    end
  end

  describe '#intersect' do
    it 'return nil when the moments does not intersect' do
      assert_nil moment.intersect(moment_after)
    end

    it 'returns a new moment that cover the common time between the two' do
      skip
      moment_a = moment.intersect(moment_during)
      moment_b = moment_during.intersect(moment)
      moment_c = moment_during.intersect(moment_cover)

      assert_equal moment_during.begin, moment_a.begin
      assert_equal moment.end, moment_a.end

      assert_equal moment_during.begin, moment_b.begin
      assert_equal moment.end, moment_b.end

      assert_equal moment_during.begin, moment_c.begin
      assert_equal moment_during.end, moment_c.end
    end

    it 'is aliased to #&' do
      assert_equal moment.method(:intersect), moment.method(:&)
    end
  end

  describe '#inspect' do
    it 'includes the class name' do
      refute_nil moment.inspect[moment.class.name]
    end

    it 'includes the start time' do
      start_at = format '%.2f', range.begin
      refute_nil moment.inspect[start_at]
    end

    it 'includes the end time' do
      end_at = format '%.2f', range.end
      refute_nil moment.inspect[end_at]
    end
  end
end