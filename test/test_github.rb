# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestGitHub < Test::Unit::TestCase

  context 'The GitHub implementation' do

    should 'not support line stats' do
      assert_not Metior::GitHub.supports? :line_stats
      object = Object.new
      object.extend Metior::GitHub
      assert_not object.supports? :line_stats
    end

    should 'not be able to get the most significant authors of a repository' do
      repo = Metior::GitHub::Repository.new 'koraktor', 'rubikon'
      assert_raises UnsupportedError do
        repo.significant_authors
      end
    end

    should 'not be able to get the most significant commits of a repository' do
      repo = Metior::GitHub::Repository.new 'koraktor', 'rubikon'
      assert_raises UnsupportedError do
        repo.significant_commits
      end
    end

  end

end
