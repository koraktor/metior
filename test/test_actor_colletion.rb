# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fixtures'
require 'helper'
require 'metior/collections/actor_collection'

class TestActorCollection < Test::Unit::TestCase

  context 'A collection of actors' do

    setup do
      repo = Metior::Git::Repository.new File.dirname(File.dirname(__FILE__))
      @@grit_commits ||= Fixtures.commits_as_grit_commits(''..'master')
      Grit::Repo.any_instance.stubs(:commits).returns @@grit_commits.values
      @@grit_commits.each do |id, commit|
        Grit::Repo.any_instance.stubs(:commit).with(id).returns commit
      end
      @authors = repo.authors
    end

    should 'be an instance of Collection' do
      assert_kind_of Collection, @authors
    end

    should 'allow to get all the commits of those actors' do
      commits = @authors.commits
      assert_instance_of CommitCollection, commits
      assert_equal 460, commits.size
      assert_equal '1b2fe77', commits.first.id
      assert_equal '80f136f', commits.last.id
    end

    should 'allow to get the commits of a single of those actors' do
      commits = @authors.commits 'tom@mojombo.com'
      assert_instance_of CommitCollection, commits
      assert_equal 173, commits.size
      assert_equal 'a3c5139', commits.first.id
      assert_equal '634396b', commits.last.id
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
