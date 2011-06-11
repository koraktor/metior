# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestGitHub < Test::Unit::TestCase

  context 'The GitHub implementation' do

    should 'not support file stats' do
      assert_not Metior::GitHub.supports? :file_stats
    end

    should 'not support line stats' do
      assert_not Metior::GitHub.supports? :line_stats
    end

  end

  context 'A GitHub repository' do

    setup do
      @repo = Metior::GitHub::Repository.new 'koraktor', 'metior'
    end

    should 'not be able to get file stats of a repository' do
      assert_raises UnsupportedError do
        @repo.file_stats
      end
    end

    should 'not be able to get the most significant authors of a repository' do
      assert_raises UnsupportedError do
        @repo.significant_authors
      end
    end

    should 'not be able to get the most significant commits of a repository' do
      assert_raises UnsupportedError do
        @repo.significant_commits
      end
    end

  end

end
