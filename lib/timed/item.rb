module Timed
  class Item < Linked::Item
    include Moment
    # The value field is used to store the timespan and shuold not be accessed
    # directly.
    
    protected :value
    private :value=
    
    # Creates a new Timed Item from a timespan. A timespan is any object that
    # responds to #begin and #end with two numerical values. Note that the end
    # must occur after the start for the span to be valid.
    #
    # If given a second argument, the two will instead be interpreted as the
    # begin and end time.
    #
    # timespan - object responding to #begin and #end.
    # end_at - if given, it togheter with the first argument will be used as the
    #          begin and end time for the item
    
    def initialize timespan, end_at = nil
      if end_at
        begin_at = timespan
      else
        begin_at = timespan.begin
        end_at = timespan.end
      end
      
      raise TypeError unless begin_at.is_a?(Numeric) && end_at.is_a?(Numeric)
      raise ArgumentError if end_at < begin_at
      
      super begin_at..end_at
    end
    
    # Returns the time when the item starts.
    
    def begin
      value.begin
    end
    
    # Returns the time when the item ends.
    
    def end
      value.end
    end

    # Returns a new Item in the intersection
    #
    # other - object that implements both #begin and #end.
    
    def intersect(other)
      begin_at = self.begin >= other.begin ? self.begin : other.begin
      end_at = self.end <= other.end ? self.end : other.end
      
      begin_at <= end_at ? self.class.new(begin_at, end_at) : nil
    end
    
    alias & intersect
    
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
  end
end
