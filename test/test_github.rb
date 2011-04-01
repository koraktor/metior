# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestGitHub < Test::Unit::TestCase

  context 'The GitHub implementation' do

    should 'not support line stats' do
      assert !Metior::GitHub.supports?(:line_stats)
    end

  end

end
