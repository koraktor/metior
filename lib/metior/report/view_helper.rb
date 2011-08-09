# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report

  # @author Sebastian Staudt
  module ViewHelper

    def count
      @count ||= 0
      @count += 1
    end

    def even_odd
      (count % 2 == 0) ? 'even' : 'odd'
    end

    def reset_count
      @count = 0
    end

  end

end
