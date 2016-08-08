module Timed
  # Timed Moment
  #
  # By including this module into any object that responds to #begin and #end,
  # it can be compared with other moments in time.
  #
  # To fully support the Moment module the following must hold:
  # a) #begin returns a Numeric value
  # b) #end returns a Numeric value larger than (or equal to) begin
  # c) a new object can be created by a single range-like argument
  
  module Moment
    # Returns the moment duration.
    
    def duration
      self.end - self.begin
    end
    
    # Returns true if the two moments begin and end on exactly the same time.
    #
    # other - object that implements both #begin and #end.
    
    def ==(other)
      self.begin == other.begin && self.end == other.end
    rescue NoMethodError
      false
    end
    
    # Returns true if the moment ends before the other one begins. If given a
    # numeric value it will be treated like instantaneous moment in time.
    #
    # other - object that implements #begin, or a numeric value.
    
    def before?(other)
      time = other.is_a?(Numeric) ? other : other.begin
      self.end <= time
    end
    
    # Returns true if the moment begins after the other one ends. If given a
    # numeric value it will be treated like instantaneous moment in time.
    #
    # other - object that implements #end, or a numeric value.
    
    def after?(other)
      time = other.is_a?(Numeric) ? other : other.end
      self.begin >= time
    end
    
    # Returns true if the moment overlaps with the other one. If given a
    # numeric value it will be treated like instantaneous moment in time.
    #
    # other - object that implements both #begin and #end, or a numeric value.
    
    def during?(other)
      if other.is_a? Numeric
        other_begin = other_end = other
      else
        other_begin, other_end = other.begin, other.end
      end
      
      self_begin, self_end = self.begin, self.end
      
      # Check if either of the two items begins during the
      # span of the other
      other_begin <= self_begin && self_begin <= other_end ||
        self_begin <= other_begin && other_begin <= self_end
    end
    
    # Returns a new moment in the intersection
    #
    # other - object that implements both #begin and #end.
    
    def intersect(other)
      begin_at = self.begin >= other.begin ? self.begin : other.begin
      end_at = self.end <= other.end ? self.end : other.end
      
      begin_at <= end_at ? self.class.new(begin_at..end_at) : nil
    end
    
    alias & intersect
    
    # Compare the moments with others.
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
    
    # Override the default implementation and provide a more useful
    # representation of the Timed Moment, including when it begins and ends.
    #
    # Example
    #   moment.inspect # => "ClassName   12.20 -> 15.50"
    #
    # Returns a string representation of the object.
    
    def inspect
      format '%s %7.2f -> %.2f', self.class.name, self.begin, self.end
    end
  end
end