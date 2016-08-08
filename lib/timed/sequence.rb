module Timed
  # Sequence
  #
  # This class implements a sequence of Timed Items. Any object that implements
  # the methods #begin and #end can be push to the sequence. Note that the items
  # must be inserted in chronological order, or the sequence will raise an
  # exception.
  #
  # Example
  #   sequence = Timed::Sequence.new
  #   sequence << 2..3
  #   sequence.prepend Timed::Item.new 1..2 # Same result as above
  #
  # A sequence can also be treated like a Moment and be compared, in time, with
  # other compatible objects.
  
  class Sequence
    include Moment
    include Linked::List

    # Returns the time at which the first item in the sequence, and therefore
    # the sequence as a whole, begins. If the sequence is empty, by convention,
    # it both begins and ends at time 0, giving it a 0 length.

    def begin
      empty? ? 0 : first.begin
    end

    # Returns the time at which the last item in the sequence, and therefore
    # the sequence as a whole, ends. If the sequence is empty, by convention,
    # it both begins and ends at time 0, giving it a 0 length.

    def end
      empty? ? 0 : last.end
    end

    # Returns the total time made up by the items

    def time
      each_item.reduce(0) { |a, e| a + e.duration }
    end

    # Extends the standard behaviour of Linked::List#first with the option of
    # only returning items that begin after a specified time.
    #
    # after - a time after which the returned item(s) must occur.
    #
    # Returns one or more items, or nil if there are no items after the given
    # time.

    def first(n = 1, after: nil, &block)
      return super(n, &block) unless after

      if include? after
        first_item_after after, n
      else
        super(n) { |item| item.after? after }
      end
    end

    # Extends the standard behaviour of Linked::List#last with the option of
    # only returning items that end before a specified time.
    #
    # after - a time after which the returned item(s) must occur.
    #
    # Returns one or more items, or nil if there are no items before the given
    # time.

    def last(n = 1, before: nil, &block)
      return super(n, &block) unless before

      if include? before
        last_item_before before, n
      else
        super(n) { |item| item.before? before }
      end
    end

    # This method takes a second sequence and iterates over each intersection
    # between the two. If a block is given, the beginning and end of each
    # intersecting period will be yielded to it. Otherwise an enumerator is
    # returned.
    #
    # other - a sequence, or object that responds to #begin and #end and returns
    #         a Timed::Item in response to #first
    #
    # Returns an enumerator unless a block is given, in which case the number of
    # intersections is returned.

    def intersections(other)
      return to_enum __callee__, other unless block_given?

      return unless during? other

      # Sort the first items from each sequence into leading
      # and trailing by whichever begins first
      if self.begin <= other.begin
        item_l, item_t = first, other.first
      else
        item_l, item_t = other.first, first
      end

      count = 0

      loop do
        # Now there are three posibilities:
        
        # 1: The leading item ends before the trailing one
        #    begins. In this case the items do not intersect
        #    at all and we do nothing.
        if item_l.end <= item_t.begin

        # 2: The leading item ends before the trailing one
        #    ends
        elsif item_l.end <= item_t.end
          yield item_t.begin, item_l.end
          count += 1

        # 3: The leading item ends after the trailing one
        else
          yield item_t.begin, item_t.end
          count += 1

          # Swap leading and trailing
          item_l, item_t = item_t, item_l
        end

        # Advance the leading item
        item_l = item_l.next

        # Swap leading and trailing if needed
        item_l, item_t = item_t, item_l if item_l.begin > item_t.begin
      end

      count
    end

    # Returns a new sequence with items that make up the intersection between
    # the two sequences.

    def intersect(other)
      intersections(other)
        .with_object(self.class.new) { |(b, e), a| a << Item.new(b, e) }
    end

    alias & intersect

    # More efficient than first calling #intersect and then #time on the result.

    def intersect_time(other)
      intersections(other).reduce(0) { |a, (b, e)| a + e - b }
    end
  end
end
