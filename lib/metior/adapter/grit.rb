# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

# The Metior implementation for Git using Grit
#
# @author Sebastian Staudt
module Metior::Adapter::Grit

  include Metior::Adapter

  as :grit
  register_for :git

end
