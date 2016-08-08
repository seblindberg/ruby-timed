module Timed
  # Timed Moment
  #
  # By including this module into any object that responds to #begin and #end,
  # it can be compared with other moments of time.
  
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
    
    # Returns true if the moment ends before the other one begins.
    #
    # other - object that implements #begin.
    
    def before?(other)
      self.end <= other.begin
    end
    
    # Returns true if the moment begins after the other one ends.
    #
    # other - object that implements #end.
    
    def after?(other)
      self.begin >= other.end
    end
    
    # Returns true if the moment overlaps with the other one.
    #
    # other - object that implements both #begin and #end.
    
    def during?(other)
      # Check if either of the two items begins during the
      # span of the other
      other.begin <= self.begin && self.begin <= other.end ||
        self.begin <= other.begin && other.begin <= self.end
    end
    
    # Returns a new moment in the intersection
    #
    # other - object that implements both #begin and #end.
    
    def intersect(other)
      begin_at = self.begin >= other.begin ? self.begin : other.begin
      end_at = self.end <= other.end ? self.end : other.end
      
      begin_at <= end_at ? self.class.new(begin_at, end_at) : nil
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