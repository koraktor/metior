# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestRepository < Test::Unit::TestCase

  context 'The base class for Metior VCS repositories' do

    setup do
      require 'metior/repository'

      @repo = Metior::Repository.new('dummy')
    end

    should 'not implement the #load_commits method' do
      assert_raise NotImplementedError do
        @repo.send(:load_commits, nil)
      end
    end

    should 'parse commit ranges correctly' do
      assert_equal 'master'..'development', @repo.send(:parse_range, 'master'..'development')
      assert_equal 'master'..'development', @repo.send(:parse_range, 'master..development')
      assert_equal ''..'master', @repo.send(:parse_range, 'master')
    end

  end

end
