# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/vcs'

module Metior

  # The Metior implementation for GitHub's API
  #
  # @author Sebastian Staudt
  module GitHub

    # GitHub will be registered as +:github+
    NAME = :github

    include Metior::VCS

    # Git's default branch is _master_
    DEFAULT_BRANCH = 'master'

  end

end

require 'metior/github/actor'
require 'metior/github/commit'
require 'metior/github/repository'
