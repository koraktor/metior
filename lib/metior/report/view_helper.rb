# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report

  # This helper module implements generic functionality that is included in all
  # report views
  #
  # @author Sebastian Staudt
  module ViewHelper

    # Increases the counter by one and returns it
    #
    # This can, for example, be used to count the values in an array that is
    # iterated in a view.
    #
    # @return [Fixnum] The current counter value
    # @see #reset_count
    def count
      @count ||= 0
      @count += 1
    end

    # Returns whether the current counter value is even or odd
    #
    # This is specifically useful for e.g. generating alternating colors of
    # table rows in the output of the view.
    #
    # @return ['even', 'odd'] `'even'` if the current counter value is even,
    #         `'odd'` otherwise.
    # @see #reset_count
    def even_odd
      (count % 2 == 0) ? 'even' : 'odd'
    end

    # Resets the current counter to 0
    #
    # @see #count
    def reset_count
      @count = 0
    end

  end

end
