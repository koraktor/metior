# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # The Metior implementation for Git
  #
  # @author Sebastian Staudt
  module Git

    # Git will be registered as `:git`
    NAME = :git

    include Metior::VCS

  end

end
