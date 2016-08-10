# frozen_string_literal: true
require 'test_helper'

describe Timed::Sequence do
  subject { ::Timed::Sequence }
  let(:item_klass) { ::Timed::Item }
  
  let(:random_time) { Random.rand 1.0..100.0 }

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

  describe '#duration' do
    it 'returns 0 for empty sequences' do
      assert_equal 0, subject.new.duration
    end

    it 'returns the time during which the sequence has items' do
      true_duration = item_b.end - item_a.begin
      assert_equal true_duration, sequence.duration
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

  describe '#first' do
    it 'behaves like the Linked::List#first' do
      assert_same item_a, sequence.first
      assert_same item_b, sequence.first(2)[1]
    end

    it 'accepts the argument after' do
      assert_same item_a, sequence.first(after: item_a.begin)
      assert_same item_b, sequence.first(after: item_a)
      assert_nil sequence.first(after: item_b)
    end
  end

  describe '#last' do
    it 'behaves like the Linked::List#last' do
      assert_same item_b, sequence.last
      assert_same item_a, sequence.last(2)[0]
    end

    it 'accepts the argument before' do
      assert_same item_b, sequence.last(before: item_b.end)
      assert_same item_a, sequence.last(before: item_b)
      assert_nil sequence.last(before: item_a)
    end
  end
  
  describe '#append' do
    it 'accepts arbitrary objects' do
      empty_sequence = subject.new
      empty_sequence << (1..9)
      assert_equal 1, empty_sequence.begin
    end
  end
  
  describe '#offset_by' do
    it 'defaults to no offset' do
      new_sequence = subject.new
      assert_equal random_time, new_sequence.offset(random_time)
    end
    
    it 'allows the offset to be removed' do
      sequence.offset_by 1
      sequence.offset_by
      assert_equal random_time, sequence.offset(random_time)
    end
    
    it 'does not perform any operations when the offset is 0' do
      sequence.offset_by 1
      sequence.offset_by 0
      
      sometime = Minitest::Mock.new
      sequence.offset sometime
    end
    
    it 'accepts a constant offset' do
      sequence.offset_by 5
      assert_equal 5 + random_time, sequence.offset(random_time)
    end
    
    it 'accepts a linear offset' do
      sequence.offset_by 5, 1.05
      assert_equal 5 + 1.05 * random_time, sequence.offset(random_time)
    end
    
    it 'accepts a quadratic offset' do
      time = 5 + 1.05 * random_time + 0.2 * random_time**2
      sequence.offset_by 5, 1.05, 0.2
      assert_equal time, sequence.offset(random_time)
    end
    
    it 'raises an error when the order is higher than 2' do
      assert_raises(ArgumentError) { sequence.offset_by 5, 1.05, 0.2, 0.1 }
    end
    
    it 'is aliased to #offset=' do
      assert_equal sequence.method(:offset_by), sequence.method(:offset=)
    end
  end

  describe '#each_edge' do
    it 'returns a sized enumerator when not given a block' do
      enum = sequence.each_edge
      assert_kind_of Enumerator, enum
      assert_equal sequence.count * 2, enum.count
    end

    it 'iterates over the edges' do
      res = []
      sequence.each_edge { |edge| res << edge }
      assert_equal item_a.begin, res[0]
      assert_equal item_a.end, res[1]
      assert_equal item_b.begin, res[2]
      assert_equal item_b.end, res[3]
    end
  end

  describe '#each_leading_edge' do
    it 'returns a sized enumerator when not given a block' do
      enum = sequence.each_leading_edge
      assert_kind_of Enumerator, enum
      assert_equal sequence.count, enum.count
    end

    it 'iterates over the leading edges' do
      res = []
      sequence.each_leading_edge { |edge| res << edge }
      assert_equal item_a.begin, res[0]
      assert_equal item_b.begin, res[1]
    end
  end

  describe '#each_trailing_edge' do
    it 'returns a sized enumerator when not given a block' do
      enum = sequence.each_trailing_edge
      assert_kind_of Enumerator, enum
      assert_equal sequence.count, enum.count
    end

    it 'iterates over the leading edges' do
      res = []
      sequence.each_trailing_edge { |edge| res << edge }
      assert_equal item_a.end, res[0]
      assert_equal item_b.end, res[1]
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
    it 'returns an empty sequence when there are no intersections' do
      sequence_1 = subject.new << item_a
      sequence_2 = subject.new << item_b

      assert sequence_1.intersect(sequence_2).empty?
    end

    it 'returns a new sequence of the intersections' do
      intersecting_sequence = sequence_1.intersect sequence_2

      assert_equal intersection_a.begin, intersecting_sequence.first.begin
      assert_equal intersection_a.end, intersecting_sequence.first.end

      assert_equal intersection_b.begin, intersecting_sequence.last.begin
      assert_equal intersection_b.end, intersecting_sequence.last.end
    end

    it 'is aliased to #&' do
      assert_equal sequence.method(:intersect), sequence.method(:&)
    end
  end

  describe '#intersect_time' do
    it 'returns 0 when there is no intersection' do
      sequence_1 = subject.new << item_a
      sequence_2 = subject.new << item_b

      assert_equal 0, sequence_1.intersect_time(sequence_2)
    end

    it 'returns the total time of the intersections' do
      time = intersection_a.duration + intersection_b.duration
      assert_equal time, sequence_1.intersect_time(sequence_2)
    end

    describe 'from:' do
      it 'affects the total' do
        from = intersection_a.begin + 1
        time = intersection_a.duration - 1 + intersection_b.duration
        assert_equal time, sequence_1.intersect_time(sequence_2, from: from)
      end

      it 'does nothing when `from` is small' do
        from = intersection_a.begin
        time = intersection_a.duration + intersection_b.duration
        assert_equal time, sequence_1.intersect_time(sequence_2, from: from)
      end

      it 'returns 0 when `from` is large' do
        from = intersection_b.end
        assert_equal 0, sequence_1.intersect_time(sequence_2, from: from)
      end
    end

    describe 'to:' do
      it 'affects the total' do
        to = intersection_b.end - 1
        time = intersection_a.duration + intersection_b.duration - 1
        assert_equal time, sequence_1.intersect_time(sequence_2, to: to)
      end

      it 'does nothing when `to` is large' do
        to = intersection_b.end
        time = intersection_a.duration + intersection_b.duration
        assert_equal time, sequence_1.intersect_time(sequence_2, to: to)
      end

      it 'returns 0 when `to` is small' do
        to = intersection_a.begin
        assert_equal 0, sequence_1.intersect_time(sequence_2, to: to)
      end
    end
  end
end
