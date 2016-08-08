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
    
    # Returns the duration of the item.
    
    def duration
      value.end - value.begin
    end
    
    # Returns true if the two items begin and end on exactly the same time.
    #
    # other - object that implements both #begin and #end.
    
    def ==(other)
      value.begin == other.begin && value.end == other.end
    rescue NoMethodError
      false
    end
    
    # Returns true if the item ends before the other one begins.
    #
    # other - object that implements #begin.
    
    def before?(other)
      value.end <= other.begin
    end
    
    # Returns true if the item begins after the other one ends.
    #
    # other - object that implements #end.
    
    def after?(other)
      value.begin >= other.end
    end
    
    # Returns true if the item overlaps with the other one.
    #
    # other - object that implements both #begin and #end.
    
    def during?(other)
      # Check if either of the two items begins during the
      # span of the other
      other.begin <= value.begin && value.begin <= other.end ||
        value.begin <= other.begin && other.begin <= value.end
    end
    
    # Returns a new Item in the intersection
    #
    # other - object that implements both #begin and #end.
    
    def intersect(other)
      begin_at = value.begin >= other.begin ? value.begin : other.begin
      end_at = value.end <= other.end ? value.end : other.end
      
      begin_at <= end_at ? self.class.new(begin_at, end_at) : nil
    end
    
    alias & intersect
    
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
      format '%s %7.2f -> %.2f', self.class.name, value.begin, value.end
    end
  end
end
