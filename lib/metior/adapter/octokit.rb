# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'metior/adapter'

# The Metior implementation for Git using GitHub's API via Octokit
#
# @author Sebastian Staudt
module Metior::Adapter::Octokit

  include Metior::Adapter

  as :octokit
  as :github
  register_for :git

  not_supporting :file_stats, :line_stats

end
