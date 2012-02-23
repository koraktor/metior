# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'
require 'metior/repository'

class TestRepository < Test::Unit::TestCase

  def setup
    @repo = Metior::Repository.new('dummy')
  end

  context 'The base class for Metior VCS repositories' do

    should 'not implement the #current_branch method method' do
      assert_raise NotImplementedError do
        @repo.current_branch
      end
    end

    should 'not implement the #id_for_ref method' do
      assert_raise NotImplementedError do
        @repo.id_for_ref nil
      end
    end

    should 'not implement the #load_branches method' do
      assert_raise NotImplementedError do
        @repo.send :load_branches
      end
    end

    should 'not implement the #load_commits method' do
      assert_raise NotImplementedError do
        @repo.send(:load_commits, nil)
      end
    end

    should 'not implement the #load_description method' do
      assert_raise NotImplementedError do
        @repo.send :load_description
      end
    end

    should 'not implement the #load_line_stats method' do
      assert_raise NotImplementedError do
        @repo.send :load_line_stats, nil
      end
    end

    should 'not implement the #load_name method method' do
      assert_raise NotImplementedError do
        @repo.send :load_name
      end
    end

    should 'not implement the #load_tags method method' do
      assert_raise NotImplementedError do
        @repo.send :load_tags
      end
    end

  end

  context 'Any Metior repository' do

    setup do
      @repo = Metior::Repository.new('dummy')
    end

    should 'load the description of the project on demand' do
      @repo.expects :load_description

      @repo.description
    end

    should 'load the name of the project on demand' do
      @repo.expects :load_name

      @repo.name
    end

    should 'parse commit ranges correctly' do
      @repo.expects(:id_for_ref).with('master').times(3).returns('abc')
      @repo.expects(:id_for_ref).with('development').twice.returns('def')

      assert_equal 'abc'..'def', @repo.send(:parse_range, 'master'..'development')
      assert_equal 'abc'..'def', @repo.send(:parse_range, 'master..development')
      assert_equal ''..'abc', @repo.send(:parse_range, 'master')
    end

    should 'miss the cache when loading a different commit range' do
      @repo.expects(:id_for_ref).with('master').returns('abc')
      @repo.expects(:id_for_ref).with('HEAD').returns('abc')
      @repo.expects(:load_commits).twice.returns([nil, []])

      @repo.commits 'master'
      @repo.commits 'HEAD'
    end

    should 'be able to get a specific actor using an ID' do
      actor, metior_actor = mock, mock
      Metior::Actor.expects(:id_for).with(actor).twice.returns 'koraktor'
      Metior::Actor.expects(:new).with(@repo, actor).once.returns metior_actor

      assert_equal metior_actor, @repo.actor(actor)
      assert_equal metior_actor, @repo.actor(actor)
    end

    should 'be able to get the authors of a specifc commit range' do
      @repo.expects(:commits).with('master').returns mock(:authors)

      @repo.authors 'master'
    end

    should 'be able to get the names of all branches in the repository' do
      branches = { 'branch_c' => '2', 'branch_a' => '1', 'branch_b' => '3' }
      @repo.expects(:load_branches).returns branches

      assert_equal %w{branch_a branch_b branch_c}, @repo.branches
    end

    should 'be able to load all commits in a specific range' do
      commits = Array.new(5) { mock }
      commits.each_with_index do |c, i|
        c.stubs :line_stats? => false, :id => i
      end
      raw_commits = mock

      @repo.expects(:parse_range).with('master').returns ''..'master'
      @repo.expects(:cached_commits).with(''..'master').returns []
      @repo.expects(:load_commits).with(''..'master').
        returns [nil, raw_commits]
      @repo.expects(:build_commits).with(raw_commits).returns commits

      commit_collection = @repo.commits 'master'
      assert_instance_of CommitCollection, commit_collection
      assert_equal commits, commit_collection.values
      assert_equal ''..'master', commit_collection.
        instance_variable_get(:@range)
    end

    should 'be able to get the committers of a specifc commit range' do
      @repo.expects(:commits).with('master').returns mock(:committers)

      @repo.committers 'master'
    end

    should 'be able to get the line history of a specifc commit range' do
      @repo.expects(:commits).with('master').returns mock(:line_history)

      @repo.line_history 'master'
    end

    should 'be able to get the most significant authors of a specifc commit range' do
      authors = mock :most_significant => 10
      @repo.expects(:authors).with('master').returns authors

      @repo.significant_authors 'master', 10
    end

    should 'be able to get the most significant commits of a specifc range' do
      commits = mock :most_significant => 10
      @repo.expects(:commits).with('master').returns commits

      @repo.significant_commits 'master', 10
    end

    should 'be able to get the names of all tags in the repository' do
      tags = { 'tag_c' => '2', 'tag_a' => '1', 'tag_b' => '3' }
      @repo.expects(:load_tags).returns tags

      assert_equal %w{tag_a tag_b tag_c}, @repo.tags
    end

    should 'be able to get the top authors of a specifc commit range' do
      authors = mock :top => 10
      @repo.expects(:authors).with('master').returns authors

      @repo.top_authors 'master', 10
    end

    should 'be able to build Metior::Commit objects for raw commits' do
      raw_commits = [
        mock(:id => 1),
        mock(:id => 2),
        mock(:id => 3)
      ]
      built_commits = [
        Metior::Commit.new(@repo),
        Metior::Commit.new(@repo),
        Metior::Commit.new(@repo)
      ]

      3.times do |i|
        built_commits[i].stubs(:id).returns raw_commits[i].id
        Metior::Commit.expects(:new).with(@repo, raw_commits[i]).
          returns built_commits[i]
      end

      commits = @repo.send :build_commits, raw_commits
      commits_cache = Hash[built_commits.map { |c| [c.id, c] }]
      assert commits.all? { |c| c.instance_of? Metior::Commit }
      assert_equal commits_cache, @repo.instance_variable_get(:@commits)
      assert_equal [1], built_commits[1].children
      assert_equal [2], built_commits[2].children
    end

  end

end
