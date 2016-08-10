module Timed
  # Sequence
  #
  # This class implements a sequence of Timed Items. Any object that implements
  # the methods #begin and #end can be added to the sequence. Note that the
  # items must be inserted in chronological order, or the sequence will raise an
  # exception.
  #
  # Example
  #   sequence = Timed::Sequence.new
  #   sequence << 2..3
  #   sequence.prepend Timed::Item.new 1..2 # Same result as above
  #
  # A sequence can also be treated like a Moment and be compared, in time, with
  # other compatible objects.
  #
  # Sequences also provide a mechanism to offset the items in it, in time by
  # providing the #offset method. Items can use it to offset their begin and end
  # times on the fly.
  #
  # Example
  #   sequence.offset_by 10, 1.1, 0.01
  #   #                  ^   ^    ^ Quadratic term
  #   #                  |   + Linear term
  #   #                  + Constant term
  #   sequence.offset 42.0 # => 73.84
  
  class Sequence
    include Moment
    include Linked::List
    
    # Provide a more ideomatic name for the identity method #list.
    
    alias sequence list

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
    
    # Offset the entire sequence by specifying the coefficients of a polynomial
    # of up to degree 2. This is then used to recalculate the begin and end
    # times of each item in the set. The operation does not change the items but
    # is instead performed on the fly every time either #begin or #end is
    # called.
    #
    # c - list of coefficients, starting with the constant term and ending with,
    #     at most, the quadratic.
    
    def offset_by(*c)
      body =
        case c.length
        when 0 then proc { |t| t }
        when 1
          if c[0] == 0 || !c[0]
            proc { |t| t }
          else
            proc { |t| c[0] + t }
          end
        when 2 then proc { |t| c[0] + c[1] * t }
        when 3 then proc { |t| c[0] + c[1] * t + c[2] * t**2 }
        else
          raise ArgumentError,
                'Only polynomilas of order 2 or lower are supported'
        end
      
      redefine_method :offset, body
    end
    
    alias offset= offset_by
    
    # Offset any time using the current offset settings of the sequence. Note
    # that this method is overridden everytime #offset_by is called.
    #
    # time - the time to be offset.
    #
    # Returns the offset time.
    
    def offset(time)
      time
    end
    
    # Iterate over all of the edges in the sequence. An edge is the point in
    # time when an item either begins or ends. That time, a numeric value, will
    # be yielded to the block. If a block is not given and enumerator is
    # returned.
    #
    # Returns an enumerator if a block was not given.
    
    def each_edge
      return to_enum __callee__ unless block_given?
      
      each_item do |item|
        yield item.begin
        yield item.end
      end
    end
    
    # Iterates over all the leading edges in the sequence. A leading edge is the
    # point in time where an item begins. That time, a numeric value, will be
    # yielded to the block. If a block is not given and enumerator is returned.
    #
    # Returns an enumerator if a block was not given.
    
    def each_leading_edge
      return to_enum __callee__ unless block_given?
      
      each_item { |item| yield item.begin }
    end
    
    # Iterates over all the trailing edges in the sequence. A trailing edge is
    # the point in time where an item begins. That time, a numeric value, will
    # be yielded to the block. If a block is not given and enumerator is
    # returned.
    #
    # Returns an enumerator if a block was not given.
    
    def each_trailing_edge
      return to_enum __callee__ unless block_given?
      
      each_item { |item| yield item.end }
    end

    # This method takes a second sequence and iterates over each intersection
    # between the two. If a block is given, the beginning and end of each
    # intersecting period will be yielded to it. Otherwise an enumerator is
    # returned.
    #
    # other - a sequence, or object that responds to #begin and #end and returns
    #         a Timed::Item in response to #first
    #
    # Returns an enumerator unless a block is given.

    def intersections(other, &block)
      return to_enum __callee__, other unless block_given?

      return unless during? other

      # Sort the first items from each sequence into leading
      # and trailing by whichever begins first
      if self.begin <= other.begin
        item_l, item_t = self.item, other.item
      else
        item_l, item_t = other.item, self.item
      end

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
      intersections(other)
        .with_object(self.class.new) { |(b, e), a| a << create_item(b, e) }
    end

    alias & intersect

    # More efficient than first calling #intersect and then #time on the result.
    #
    # from - a point in time to start from.
    # to - a point in time to stop at.
    #
    # Returns the total time of the intersection between this sequence and the
    # other one.

    def intersect_time(other, from: nil, to: nil)
      enum = intersections(other)
      total = 0
      
      if from
        # Reuse the variable total. It's perhaps a bit messy
        # and confusing but it works.
        _, total = enum.next until total > from
        total -= from
      end
      
      if to
        loop do
          b, e = enum.next
          
          if e > to
            total += to - b unless b >= to
            break
          end
          
          total += e - b
        end
      else
        loop do
          b, e = enum.next
          total += e - b
        end
      end
      
      total
    rescue StopIteration
      return 0
    end
    
    # Protected factory method for creating items compatible with the sequence.
    # This method is called whenever an arbitrary object is pushed or unshifted
    # onto the list and need to be wraped inside an Item.
    #
    # args - any arguments will be passed on to Item.new.
    #
    # Returns a new Item.
    
    protected def create_item(*args)
      Item.new(*args)
    end
    
    # Private helper method for (re)defining method on the singleton class.
    #
    # name - symbol name of the method.
    # body - proc that will be used as method body.
    
    private def redefine_method name, body
      singleton_class.send :remove_method, name
    rescue NameError
    ensure
      singleton_class.send :define_method, name, body
    end
  end
end
