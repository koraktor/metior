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

    should 'hit the cache when loading the same commit range' do
      @repo.expects(:load_commits).once.returns([])

      @repo.commits 'master'
      @repo.commits 'master'
    end

    should 'miss the cache when loading a different commit range' do
      @repo.expects(:load_commits).twice.returns([])

      @repo.commits 'master'
      @repo.commits 'HEAD'
    end

  end

  context 'A repository implementation' do

    setup do
      require 'mock_vcs/repository'

      repo_file = "#{File.dirname(__FILE__)}/fixtures/mojombo-grit-master-1b2fe77.txt"
      @repo = MockVCS::Repository.new repo_file
      @repo.commits
    end

    should 'be able to load the commits of the repository' do
      commits = @repo.commits
      assert_equal 415, commits.size
      assert commits.all? { |commit| commit.is_a? Metior::Commit }

      head = commits.first
      assert_equal '4c592b4', head.id
    end

    should 'know the authors of the repository' do
      authors = @repo.authors
      assert_equal 37, authors.size
      assert authors.values.all? { |author| author.is_a? Metior::Actor }

      assert_equal %w{
        adam@therealadam.com aman@tmm1.net antonin@hildebrand.cz
        bobbywilson0@gmail.com bryce@worldmedia.net cehoffman@gmail.com
        chapados@sciencegeeks.org cho45@lowreal.net chris@ozmm.org
        davetron5000@gmail.com david.kowis@rackspace.com dustin@spy.net
        engel@engel.uk.to evil@che.lu gram.gibson@uky.edu
        hiroshi3110@gmail.com igor@wiedler.ch johan@johansorensen.com
        jos@catnook.com jpriddle@nevercraft.net kamal.fariz@gmail.com
        koraktor@gmail.com mtraverso@acm.org ohnobinki@ohnopublishing.net
        paul+git@mjr.org pjhyett@gmail.com rsanheim@gmail.com
        rtomayko@gmail.com schacon@gmail.com scott@railsnewbie.com
        technoweenie@gmail.com tim@dysinger.net tim@spork.in
        tom@mojombo.com tom@taco.(none) voker57@gmail.com wayne@larsen.st
      }, authors.keys.sort
    end

    should 'know the committers of the repository' do
      committers = @repo.committers
      assert_equal 29, committers.size
      assert committers.values.all? { |committer| committer.is_a? Metior::Actor }

      assert_equal %w{
         adam@therealadam.com aman@tmm1.net antonin@hildebrand.cz
         bobbywilson0@gmail.com bryce@worldmedia.net chris@ozmm.org
         davetron5000@gmail.com david.kowis@rackspace.com dustin@spy.net
         engel@engel.uk.to evil@che.lu hiroshi3110@gmail.com
         johan@johansorensen.com jos@catnook.com kamal.fariz@gmail.com
         koraktor@gmail.com mtraverso@acm.org ohnobinki@ohnopublishing.net
         paul+git@mjr.org pjhyett@gmail.com rsanheim@gmail.com
         rtomayko@gmail.com schacon@gmail.com technoweenie@gmail.com
         tim@dysinger.net tim@spork.in tom@mojombo.com tom@taco.(none)
         voker57@gmail.com
      }, committers.keys.sort
    end

    should 'know the most significant authors of the repository' do
      authors = @repo.significant_authors
      assert_equal 3, authors.size
      assert authors.all? { |author| author.is_a? Metior::Actor }

      assert_equal [
        "tom@mojombo.com", "schacon@gmail.com", "rtomayko@gmail.com"
      ], authors.collect { |author| author.id }
    end

    should 'know the most significant commits of the repository' do
      commits = @repo.significant_commits
      assert_equal 10, commits.size
      assert commits.all? { |commit| commit.is_a? Metior::Commit }

      assert_equal [
        "c0f0b4f", "47ab25c", "f3a24ae", "18ec70e", "242253b", "c87612b",
        "6bb41e4", "4d9c7be", "756a947", "7569d0d"
      ], commits.collect { |commit| commit.id }

      modifications = commits.first.modifications
      commits[1..-1].each do |commit|
        assert modifications >= commit.modifications
        modifications = commit.modifications
      end
    end

    should 'know the top authors of the repository' do
      authors = @repo.top_authors
      assert_equal 3, authors.size
      assert authors.all? { |author| author.is_a? Metior::Actor }

      assert_equal [
        "tom@mojombo.com", "schacon@gmail.com", "technoweenie@gmail.com"
      ], authors.collect { |author| author.id }
    end

  end

end
