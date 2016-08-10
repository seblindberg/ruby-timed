module Timed
  # Item
  #
  # The Timed Item is a Moment that can be chained to others to form a sequence.
  # Importantly, items in a sequence are guaranteed to be sequential and non
  # overlapping.

  class Item < Linked::Item
    include Moment

    # The value field is used to store the timespan and shuold not be accessed
    # directly.

    protected :value
    private :value=

    # Provide a more ideomatic accessor for the sequence that the item is part
    # of.

    alias sequence list
    alias in_sequence? in_list?

    # Creates a new Timed Item from a timespan. A timespan is any object that
    # responds to #begin and #end with two numerical values. Note that the end
    # must occur after the start for the span to be valid.
    #
    # If given a second argument, the two will instead be interpreted as the
    # begin and end time.
    #
    # timespan - object responding to #begin and #end.
    # end_at - if given, it togheter with the first argument will be used as the
    #          begin and end time for the item.
    # sequence - optional sequence to add the item to.

    def initialize(timespan, end_at = nil, sequence: nil)
      if end_at
        begin_at = timespan
      else
        begin_at = timespan.begin
        end_at = timespan.end
      end

      raise TypeError unless begin_at.is_a?(Numeric) && end_at.is_a?(Numeric)
      raise ArgumentError if end_at < begin_at

      super begin_at..end_at, list: sequence
    end

    # Returns the time when the item starts.

    def begin
      offset value.begin
    end

    # Returns the time when the item ends.

    def end
      offset value.end
    end

    # Inserts an item after this one and before the next in the sequence. The
    # new item may not overlap with the two it sits between. A RuntimeError will
    # be raised if it does.
    #
    # If the given object is an Item it will be inserted directly. Otherwise, if
    # the object responds to #begin and #end, a new Item will be created from
    # that timespan.

    def append(other)
      raise RuntimeError unless before? other
      raise RuntimeError unless last? || after?(self.next)

      super
    end

    # Inserts an item before this one and after the previous in the sequence.
    # The new item may not overlap with the two it sits between. A RuntimeError
    # will be raised if it does.
    #
    # If the given object is an Item it will be inserted directly. Otherwise, if
    # the object responds to #begin and #end, a new Item will be created from
    # that timespan.

    def prepend(other)
      raise RuntimeError unless after? other
      raise RuntimeError unless first? || before?(previous)

      super
    end

    protected def offset(time)
      in_sequence? ? sequence.offset(time) : time
    end
  end
end
