# frozen_string_literal: true
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

    it 'returns the number of intersections' do
      count = sequence_1.intersections(sequence_2) {}
      assert_equal 2, count
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
      true_time = intersection_a.duration + intersection_b.duration
      assert_equal true_time, sequence_1.intersect_time(sequence_2)
    end
  end
end
