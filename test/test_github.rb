# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fixtures'
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
      @repo = Metior::GitHub::Repository.new 'mojombo', 'grit'

      @@github_commits = Fixtures.commits_as_rashies(''..'master')
      api_response = @@github_commits.values
      @commits_stub = Octokit.stubs :commits
      14.times { @commits_stub.returns api_response.shift(35) }
      @commits_stub.then.raises Octokit::NotFound.new(nil)

      @repo.stubs(:id_for_ref).with('master').returns('1b2fe77')
    end

    should 'be able to load all commits from the repository\'s default branch' do
      @repo.expects(:id_for_ref).with('master').once.returns('1b2fe77')

      commits = @repo.commits
      assert_equal 460, commits.size
      assert commits.all? { |commit| commit.is_a? Metior::GitHub::Commit }

      head = commits.first
      assert_equal '1b2fe77', head.id
    end

    should 'be able to load a range of commits from the repository' do
      api_response = Fixtures.commits_as_rashies('ef2870b'..'4c592b4').values
      Octokit.stubs(:commits).returns(api_response).
        raises(Octokit::NotFound.new nil)

      @repo.expects(:id_for_ref).with('ef2870b').once.returns('ef2870b')
      @repo.expects(:id_for_ref).with('4c592b4').once.returns('4c592b4')

      commits = @repo.commits 'ef2870b'..'4c592b4'
      assert_equal 6, commits.size
      assert commits.all? { |commit| commit.is_a? Metior::GitHub::Commit }
      assert_equal '4c592b4', commits.first.id
      assert_equal 'f0cc7f7', commits.last.id
    end

    should 'know the authors of the repository' do
      authors = @repo.authors
      assert_equal 37, authors.size
      assert authors.values.all? { |author| author.is_a? Metior::GitHub::Actor }

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
      assert committers.values.all? { |committer| committer.is_a? Metior::GitHub::Actor }

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

    should 'know the top authors of the repository' do
      authors = @repo.top_authors
      assert_equal 3, authors.size
      assert authors.all? { |author| author.is_a? Metior::GitHub::Actor }

      assert_equal [
        "tom@mojombo.com", "schacon@gmail.com", "technoweenie@gmail.com"
      ], authors.collect { |author| author.id }
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

    should 'provide easy access to simple repository statistics' do
      Metior::GitHub::Repository.any_instance.expects(:id_for_ref).twice.
        with('master').returns('1b2fe77')

      stats = Metior.simple_stats :github, 'mojombo/grit'

      assert_equal 157, stats[:active_days].size
      assert_equal 460, stats[:commit_count]
      assert_in_delta 2.92993630573248, stats[:commits_per_active_day], 0.0001
      assert_equal Time.at(1191997100), stats[:first_commit_date]
      assert_equal Time.at(1306794294), stats[:last_commit_date]
      assert_equal 5, stats[:top_contributors].size
    end

    should 'be able to load all the branches of a repository' do
      branches = {
        'master' => '1b2fe77',
        'branch1' => '1234567',
        'branch2' => '0abcdef'
      }
      Octokit.expects(:branches).with('mojombo/grit').once.returns(branches)

      assert_equal %w{branch1 branch2 master}, @repo.branches
      assert_equal branches, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load all tags of a repository' do
      tags = {
        'v2.3.1' => '034fc81',
        'v2.4.0' => 'a3c5139',
        'v2.4.1' => '91940c2'
      }
      Octokit.expects(:tags).with('mojombo/grit').once.returns(tags)

      assert_equal %w{v2.3.1 v2.4.0 v2.4.1}, @repo.tags
      assert_equal tags, @repo.instance_variable_get(:@refs)
    end

    should 'be able to load the name and description of the project' do
      repo = Hashie::Mash.new({
        :name        => 'grit',
        :description => 'Grit gives you object oriented read/write access to Git repositories via Ruby.'
      })
      Octokit.expects(:repo).with('mojombo/grit').once.returns repo
      @repo.expects(:load_description).never

      assert_equal repo.name, @repo.name
      assert_equal repo.description, @repo.description
    end

  end

end
