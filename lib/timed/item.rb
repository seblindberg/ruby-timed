module Timed
  class Item < Linked::Item
    # The value field is used to store the timespan and shuold not be accessed
    # directly.
    
    protected :value
    private :value=
    
    # Creates a new Timed Item from a timespan. A timespan is any object that
    # responds to #begin and #end with two numerical values. Note that the end
    # must occur after the start for the span to be valid.
    #
    # timespan - object responding to #begin and #end.
    
    def initialize timespan
      begin_at = timespan.begin
      end_at = timespan.end
      
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
    
    # Returns the duration of the item.
    
    def duration
      self.end - self.begin
    end
    
    # Returns true if the item ends before the other one begins.
    
    def before?(other)
      self.end <= other.begin
    end
    
    # Returns true if the item begins after the other one ends.
    
    def after?(other)
      self.begin >= other.end
    end
    
    # Returns true if the item overlaps with the other one.
    
    def during?(other)
      # Check if either of the two items begins during the
      # span of the other
      other.begin <= self.begin && self.begin <= other.end ||
        self.begin <= other.begin && other.begin <= self.end
    end
    
    # Compare the item with others.
    #
    # Return -1 if the item is before the other, 0 if they overlap and 1 if the
    # item is after the other.
    
    # def <=>(other)
    #   case
    #   when before?(other) then -1
    #   when after?(other) then 1
    #   else 0
    #   end
    # end
    
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
    
    # Override the default implementation and provide a more useful
    # representation of the Timed Item, including when it begins and ends.
    #
    # Example
    #   item.inspect # => "Timed::Item   12.20 -> 15.50"
    #
    # Returns a string representation of the object.
    
    def inspect
      format '%s %7.2f -> %.2f', self.class.name, self.begin, self.end
    end
  end
end
