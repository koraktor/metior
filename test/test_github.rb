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
      @repo = Metior::GitHub::Repository.new 'some/repo'
    end

    should 'be able to load all commits from the repository\'s default branch' do
      first_page  = Array.new(35) { |x| mock :id => x }
      second_page = Array.new(35) { |x| mock :id => 35 + x }

      Octokit.expects(:commits).with('some/repo', 'master', { :page => 1 }).
        returns first_page
      Octokit.expects(:commits).with('some/repo', 'master', { :page => 2 }).
        returns second_page
      Octokit.expects(:commits).with('some/repo', 'master', { :page => 3 }).
        raises Octokit::NotFound

      commits = @repo.send :load_commits, ''..'master'
      assert_equal [nil, first_page + second_page], commits
    end

    should 'be able to load a range of commits from the repository' do
      first_page  = Array.new(35) { |x| mock :id => x.to_s }
      second_page = Array.new(35) { |x| mock }
      base_commit = second_page.first
      base_commit.expects(:id).returns '35'

      Octokit.expects(:commits).with('some/repo', 'master', { :page => 1 }).
        returns first_page
      Octokit.expects(:commits).with('some/repo', 'master', { :page => 2 }).
        returns second_page

      commits = @repo.send :load_commits, '35'..'master'
      assert_equal [base_commit, first_page], commits
    end

    should 'be able to load all the branches of a repository' do
      branches = {
        'master' => '1b2fe77',
        'branch1' => '1234567',
        'branch2' => '0abcdef'
      }
      Octokit.expects(:branches).with('some/repo').once.returns(branches)

      assert_equal %w{branch1 branch2 master}, @repo.branches
      assert_equal branches, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load all tags of a repository' do
      tags = {
        'v2.3.1' => '034fc81',
        'v2.4.0' => 'a3c5139',
        'v2.4.1' => '91940c2'
      }
      Octokit.expects(:tags).with('some/repo').once.returns(tags)

      assert_equal %w{v2.3.1 v2.4.0 v2.4.1}, @repo.tags
      assert_equal tags, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load the name and description of the project' do
      repo = Hashie::Mash.new({
        :name        => 'grit',
        :description => 'Grit gives you object oriented read/write access to Git repositories via Ruby.'
      })
      Octokit.expects(:repo).with('some/repo').once.returns repo
      @repo.expects(:load_description).never

      assert_equal repo.name, @repo.name
      assert_equal repo.description, @repo.description
    end

    should 'be able to load the commit SHA ID for a given ref' do
      commit = mock :id => 'deadbeef'
      Octokit.expects(:commit).with('some/repo', 'master').returns commit

      assert_equal 'deadbeef', @repo.send(:id_for_ref, 'master')
    end

  end

end
