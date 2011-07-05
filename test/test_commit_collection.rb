# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fixtures'
require 'helper'
require 'metior/collections/commit_collection'

class TestCommitCollection < Test::Unit::TestCase

  context 'A collection of commits' do

    setup do
      repo = Metior::Git::Repository.new File.dirname(File.dirname(__FILE__))
      @@grit_commits ||= Fixtures.commits_as_grit_commits(''..'master')
      Grit::Repo.any_instance.stubs(:commits).returns @@grit_commits
      @commits = repo.commits
    end

    should 'be an instance of Collection' do
      assert @commits.is_a? Collection
    end

    should 'allow to get all the authors of those commits' do
      authors = @commits.authors
      assert authors.is_a? ActorCollection
      assert_equal 37, authors.size
      assert_equal 'rtomayko@gmail.com', authors.first.id
      assert_equal 'tom@taco.(none)', authors.last.id
    end

    should 'allow to get the author of a single of those commits' do
      authors = @commits.authors '4c592b4'
      assert authors.is_a? ActorCollection
      assert_equal 1, authors.size
      assert_equal 'bobbywilson0@gmail.com', authors.first.id
    end

    should 'allow to get all commits of a specific author' do
      commits = @commits.by 'rtomayko@gmail.com'
      assert commits.is_a? CommitCollection
      assert_equal 47, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal 'd731f85', commits.last.id
    end

    should 'allow to get all commits of a some authors' do
      commits = @commits.by 'tom@mojombo.com', 'rtomayko@gmail.com'
      assert commits.is_a? CommitCollection
      assert_equal 220, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal '634396b', commits.last.id
    end

    should 'allow to get all commits after a given date' do
      commits = @commits.after '31-12-2010'
      assert commits.is_a? CommitCollection
      assert_equal 29, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal '696761d', commits.last.id
    end

    should 'allow to get all commits before a given date' do
      commits = @commits.before '31-12-2009'
      assert commits.is_a? CommitCollection
      assert_equal 325, commits.size
      assert_equal '2f1f63e', commits.first.id
      assert_equal '634396b', commits.last.id
    end

    should 'allow to get all the committers of those commits' do
      committers = @commits.committers
      assert committers.is_a? ActorCollection
      assert_equal 29, committers.size
      assert_equal 'rtomayko@gmail.com', committers.first.id
      assert_equal 'tom@taco.(none)', committers.last.id
    end

    should 'allow to get the committers of a single of those commits' do
      committers = @commits.committers '4c592b4'
      assert committers.is_a? ActorCollection
      assert_equal 1, committers.size
      assert_equal 'bobbywilson0@gmail.com', committers.first.id
    end

    should 'allow to get the activity statistics of those commits' do
      activity = @commits.activity
      assert_instance_of Hash, activity
      assert_instance_of Hash, activity[:active_days]
      assert_equal 157, activity[:active_days].size
      assert activity[:active_days].keys.all? { |k| k.is_a? Time }
      assert activity[:active_days].values.all? { |v| v.is_a? Fixnum }
      assert_in_delta 2.9299, activity[:commits_per_active_day], 0.0001
      assert_equal Time.at(1191997100), activity[:first_commit_date]
      assert_equal Time.at(1306794294), activity[:last_commit_date]
      assert_equal Time.parse('14-02-2009 00:00 +0000'), activity[:most_active_day]
    end

    should 'allow to get all commits changing specified files' do
      commits = @commits.changing('lib/grit.rb')
      assert commits.is_a? CommitCollection
      assert_equal 57, commits.size
      assert_equal '18bfda9', commits.first.id
      assert_equal '634396b', commits.last.id
    end

  end

end
