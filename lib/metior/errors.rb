# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # This error is raised when an operation is not supported by the currently
  # used VCS (or its implementation)
  class UnsupportedError < RuntimeError

    # Creates a new instance of this error
    def initialize
      super 'Operation not supported by the current VCS.'
    end

  end

end
