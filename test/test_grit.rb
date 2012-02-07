# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'

class TestGrit < Test::Unit::TestCase

  context 'The Grit adapter' do

    should 'support file stats' do
      assert Metior::Adapter::Grit.supports? :file_stats
    end

    should 'support line stats' do
      assert Metior::Adapter::Grit.supports? :line_stats
    end

  end

  context 'A Grit repository' do

    setup do
      @grit_repo = mock
      ::Grit::Repo.stubs(:new).with('/path/to/repo').returns @grit_repo
      @repo = Metior::Adapter::Grit::Repository.new '/path/to/repo'
    end

    should 'be able to load all commits from the repository\'s default branch' do
      grit_commits = Array.new(50) { mock }
      output = mock
      @grit_git = mock

      @grit_repo.expects(:commit).never
      @grit_repo.expects(:git).returns @grit_git
      @grit_git.expects(:native).with(:rev_list, anything, 'master').
        returns output
      ::Grit::Commit.expects(:list_from_string).with(@grit_repo, output).
        returns grit_commits

      commits = @repo.send :load_commits, ''..'master'
      assert_equal [nil, grit_commits], commits
    end

    should 'be able to load a range of commits from the repository' do
      base_commit  = mock
      grit_commits = Array.new(50) { mock }
      output = mock
      @grit_git = mock

      @grit_repo.expects(:commit).with('deadbeef').returns base_commit
      @grit_repo.expects(:git).returns @grit_git
      @grit_git.expects(:native).with(:rev_list, anything, 'deadbeef..master').
        returns output
      ::Grit::Commit.expects(:list_from_string).with(@grit_repo, output).
        returns grit_commits

      commits = @repo.send :load_commits, 'deadbeef'..'master'
      assert_equal [base_commit, grit_commits], commits
    end

    should 'be able to load all the branches of a repository' do
      branches = {
        'master' => '1b2fe77',
        'branch1' => '1234567',
        'branch2' => '0abcdef'
      }
      grit_branches = branches.map do |branch, id|
        mock :commit => (mock :id => id), :name => branch
      end
      @grit_repo.expects(:branches).once.returns(grit_branches)

      assert_equal %w{branch1 branch2 master}, @repo.branches
      assert_equal branches, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load all tags of a repository' do
      tags = {
        'v2.3.1' => '034fc81',
        'v2.4.0' => 'a3c5139',
        'v2.4.1' => '91940c2'
      }
      grit_tags = tags.map do |tag, id|
        mock :commit => (mock :id => id), :name => tag
      end
      @grit_repo.expects(:tags).once.returns(grit_tags)

      assert_equal %w{v2.3.1 v2.4.0 v2.4.1}, @repo.tags
      assert_equal tags, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load the name and description of the project' do
      description = "grit\n\nGrit gives you object oriented read/write access to Git repositories via Ruby."
      @grit_repo.expects(:description).once.returns description
      @repo.expects(:load_description).never

      assert_equal 'grit', @repo.name
      assert_equal 'Grit gives you object oriented read/write access to Git repositories via Ruby.', @repo.description
    end

    should 'ignore the default Git description file' do
      description = "Unnamed repository; edit this file 'description' to name the repository."
      @grit_repo.expects(:description).once.returns description
      @repo.expects(:load_description).never

      assert_equal '', @repo.name
      assert_equal '', @repo.description
    end

    should 'be able to load a raw Grit::Commit' do
      commit = mock
      @grit_repo.expects(:commit).with('deadbeef').returns commit

      assert_equal commit, @repo.raw_commit('deadbeef')
    end

    should 'be able to load the commit SHA ID for a given ref' do
      @grit_git = mock
      @grit_git.expects(:native).with(:rev_parse, anything, 'master^{}').
        returns "deadbeef\n"
      @grit_repo.expects(:git).returns @grit_git

      assert_equal 'deadbeef', @repo.id_for_ref('master')
    end

    should 'be able to load the line stats for a range of commits' do
      commit_stats = Array.new(20) do |x|
        [x, mock(:additions => x, :deletions => x)]
      end
      line_stats = Hash[Array.new(20) { |x| [x, [x, x]] }]

      output = mock
      @grit_git = mock
      @grit_repo.expects(:git).returns @grit_git
      @grit_git.expects(:native).with(:log, anything, 'master').returns output
      ::Grit::CommitStats.expects(:list_from_string).with(@grit_repo, output).
        returns commit_stats

      assert_equal line_stats, @repo.load_line_stats(''..'master')
    end

    should 'be able to load the line stats for a given set of commits' do
      ids = Array.new(5) { |x| x }
      commit_stats = Array.new(20) do |x|
        [x, mock(:additions => x, :deletions => x)]
      end
      line_stats = Hash[Array.new(20) { |x| [x, [x, x]] }]

      output = mock
      @grit_git = mock
      @grit_repo.expects(:git).returns @grit_git
      @grit_git.expects(:native).with(:log, anything, *ids).returns output
      ::Grit::CommitStats.expects(:list_from_string).with(@grit_repo, output).
        returns commit_stats

      assert_equal line_stats, @repo.load_line_stats(ids)
    end

    should 'be able to get the current branch of a repository' do
      head = mock
      head.expects(:name).returns 'master'
      @grit_repo.expects(:head).returns head

      assert_equal 'master', @repo.current_branch
    end

  end

end
