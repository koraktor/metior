# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'metior/vcs'

# The VCS module for Git
#
# @author Sebastian Staudt
module Metior::VCS::Git

  include Metior::VCS

  as :git
  default_adapter :grit

end

require 'metior/adapter/grit'
require 'metior/adapter/octokit'
