# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestGit < Test::Unit::TestCase

  context 'The Git implementation' do

    should 'support line stats' do
      assert Metior::Git.supports?(:line_stats)
    end

  end

end
