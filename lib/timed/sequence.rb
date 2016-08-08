module Timed
  class Sequence
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
    
    # Returns the length of the enture sequence
    
    def length
      empty? ? 0 : last.end - first.begin
    end
    
    # Returns the total time made up by the items
    
    def time
      each_item.reduce(0) { |a, e| a + e.duration }
    end
    
    # This method takes a second sequence and iterates over each intersection
    # between the two. If a block is given, the begin and end of each
    # intersecting period will be yielded to it. Otherwise an enumerator is
    # returned.
    #
    # other - a sequence, or object that returns en enumerator yielding items in
    #         response to #each_item.
    
    def intersections(other)
      return to_enum __callee__, other unless block_given?
      
      # Sort the first items from each sequence into leading
      # and trailing by whichever begins first
      if self.begin <= other.begin
        item_l = first
        item_t = other.first
      else
        item_l = other.first
        item_t = first
      end
      
      loop do
        # Now there are three posibilities:
        case
        # 1: The leading item ends before the trailing one
        #    begins. In this case the items do not intersect
        #    at all and we do nothing.
        when item_l.end <= item_t.begin
          
        # 2: The leading item ends before the trailing one
        #    ends
        when item_l.end <= item_t.end
          yield item_t.begin, item_l.end
        
        # 3: The leading item ends after the trailing one
        else
          yield item_t.begin, item_t.end
          
          # Swap leading and trailing
          item_l, item_t = item_t, item_l
        end
        
        # Advance the leading item
        item_l = item_l.next
        
        # Swap leading and trailing if needed
        item_l, item_t = item_t, item_l if item_l.begin > item_t.begin
      end
    end
    
    # Returns a new sequence with items that make up the intersection between
    # the two sequences.
    
    def intersect(other)
      sequence = self.class.new
      mutable_range = Struct.new(:begin, :end).new(0, 0)
      
      intersections other do |b, e|
        mutable_range.begin = b
        mutable_range.end = e
        
        sequence << mutable_range
      end
    end
    
    # More efficient than first calling #intersect and then #time on the result.
    
    def intersect_time(other)
      intersections(other).reduce(0) { |a, (b, e)| a + e - b }
    end
  end
end
