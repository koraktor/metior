# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # The Metior implementation for GitHub's API
  #
  # @author Sebastian Staudt
  module GitHub

    # GitHub will be registered as `:github`
    NAME = :github

    include Metior::VCS

    # Git's default branch is _master_
    DEFAULT_BRANCH = 'master'

    not_supported :file_stats, :line_stats

  end

end
