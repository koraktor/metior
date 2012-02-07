# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

module Metior

  # This error is raised when a file cannot be found for a specifc report (or
  # one of its ancestors)
  #
  # @author Sebastian Staudt
  class FileNotFoundError < RuntimeError

    # Creates a new instance of this error
    #
    # @param [String] file The relative path of the file that could not be
    #        found
    # @param [Class] report The class of the report that included this file
    def initialize(file, report)
      super "'%s' could not be found in report :%s." % [ file, report.name ]
    end

  end

  # This error is raised when an operation is not supported by the currently
  # used VCS (or its implementation)
  class UnsupportedError < RuntimeError

    # Creates a new instance of this error
    def initialize(vcs)
      super 'Operation not supported by the current VCS (:%s).' % vcs::NAME
    end

  end

end
