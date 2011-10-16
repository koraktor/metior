# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'metior/collections/actor_collection'

class TestActorCollection < Test::Unit::TestCase

  context 'An empty actor collection' do

    should 'not fail for any method' do
      @actors = ActorCollection.new
      assert_nothing_raised do
        @actors.authored_commits
        @actors.committed_commits
        @actors.most_significant
        @actors.top
      end
    end

  end

  context 'A collection of actors' do

    setup do
      repo = Metior::Git::Repository.new File.dirname(File.dirname(__FILE__))
      repo.stubs(:current_branch).returns 'master'
      @@grit_commits ||= Fixtures.commits_as_grit_commits(''..'master')
      Grit::Git.any_instance.stubs(:native).with(:rev_list, anything, anything)
      Grit::Git.any_instance.stubs(:native).
        with(:rev_parse, anything, 'master^{}').returns '1b2fe77'
      Grit::Commit.stubs(:list_from_string).returns @@grit_commits.values
      @@grit_commits.each do |id, commit|
        Grit::Repo.any_instance.stubs(:commit).with(id).returns commit
      end
      @authors = repo.authors
      @authors.commits.each do |commit|
        commit.line_stats = @@grit_commits[commit.id].stats.additions,
                            @@grit_commits[commit.id].stats.deletions
      end
    end

    should 'be an instance of Collection' do
      assert_kind_of Collection, @authors
    end

    should 'allow to get all the commits authored by those actors' do
      commits = @authors.authored_commits
      assert_instance_of CommitCollection, commits
      assert_equal 460, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal '80f136f', commits.last.id
    end

    should 'allow to get the commits authored by a single of those actors' do
      commits = @authors.authored_commits 'tom@mojombo.com'
      assert_instance_of CommitCollection, commits
      assert_equal 173, commits.size
      assert_equal 'a3c5139', commits.first.id
      assert_equal '634396b', commits.last.id
    end

    should 'allow to get all the commits committed by those actors' do
      commits = @authors.committed_commits
      assert_instance_of CommitCollection, commits
      assert_equal 460, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal '80f136f', commits.last.id
    end

    should 'allow to get the commits committed by a single of those actors' do
      commits = @authors.committed_commits 'technoweenie@gmail.com'
      assert_instance_of CommitCollection, commits
      assert_equal 55, commits.size
      assert_equal 'ed1b3ae', commits.first.id
      assert_equal 'c9cf68f', commits.last.id
    end

    should 'allow to get the most significant actors' do
      authors = @authors.most_significant
      assert_instance_of ActorCollection, authors
      assert_equal 3, authors.size
      assert_equal 'tom@mojombo.com', authors.first.id
      assert_equal 'rsanheim@gmail.com', authors.last.id
    end

    should 'allow to get the top contributing actors' do
      authors = @authors.top
      assert_instance_of ActorCollection, authors
      assert_equal 3, authors.size
      assert_equal 'tom@mojombo.com', authors.first.id
      assert_equal 'technoweenie@gmail.com', authors.last.id
    end

  end

end
