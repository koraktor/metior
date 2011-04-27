# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/actor'
require 'metior/errors'

module Metior

  # This class represents a source code repository.
  #
  # @abstract It has to be subclassed to implement a repository representation
  #           for a specific VCS.
  # @author Sebastian Staudt
  class Repository

    # @return [String] The file system path of this repository
    attr_reader :path

    # Creates a new repository instance with the given file system path
    #
    # @param [String] path The file system path of the repository
    def initialize(path)
      @authors    = {}
      @commits    = {}
      @committers = {}
      @path       = path
    end

    # Returns all authors from the given branch in a hash where the IDs of the
    # authors are the keys and the authors are the values
    #
    # This will call +commits(branch)+ if the authors for the branch are not
    # known yet.
    #
    # @param [String] branch The branch from which the authors should be
    #        retrieved
    # @param [String] base Only commits not contained in +base+ will be listed
    # @return [Hash<String, Actor>] All authors from the given branch
    # @see #commits
    def authors(branch = self.class::DEFAULT_BRANCH, base = nil)
      commits(branch, base) if @authors[branch].nil?
      @authors[branch]
    end
    alias_method :contributors, :authors

    # Loads all commits including their committers and authors from the given
    # branch
    #
    # @param [String] branch The branch to load commits from
    # @param [String] base Only commits not contained in +base+ will be listed
    # @return [Array<Commit>] All commits from the given branch
    def commits(branch = DEFAULT_BRANCH, base = nil)
      if @commits[branch].nil?
        @authors[branch]    = {}
        @committers[branch] = {}
        @commits[branch]    = []
        load_commits(branch, base).each do |git_commit|
          commit = self.class::Commit.new(self, branch, git_commit)
          @commits[branch] << commit
          @authors[branch][commit.author.id]       = commit.author
          @committers[branch][commit.committer.id] = commit.committer
        end
      end

      @commits[branch]
    end

    # Returns all committers from the given branch in a hash where the IDs of
    # the committers are the keys and the committers are the values
    #
    # This will call +commits(branch)+ if the committers for the branch are not
    # known yet.
    #
    # @param [String] branch The branch from which the committers should be
    #        retrieved
    # @param [String] base Only commits not contained in +base+ will be listed
    # @return [Hash<String, Actor>] All committers from the given branch
    # @see #commits
    def committers(branch = self.class::DEFAULT_BRANCH, base = nil)
      commits(branch, base) if @committers[branch].nil?
      @committers[branch]
    end
    alias_method :collaborators, :committers

    # This evaluates the changed lines in each commit of the given branch.
    #
    # For easier use, the values are stored in separate arrays where each
    # number represents the number of changed (i.e. added or deleted) lines in
    # one commit.
    #
    # @example
    #  repo.line_history
    #  => { :additions => [10, 5, 0], :deletions => [0, -2, -1] }
    # @param [String] branch The branch from which the commit stat should be
    #        retrieved
    # @param [String] base Only commits not contained in +base+ will be listed
    # @return [Hash<Symbol, Array>] Added lines are returned in an +Array+
    #         assigned to key +:additions+, deleted lines are assigned to
    #         +:deletions+
    # @see Commit#additions
    # @see Commit#deletions
    def line_history(branch = self.class::DEFAULT_BRANCH, base = nil)
      raise UnsupportedError unless supports? :line_stats

      history = { :additions => [], :deletions => [] }
      commits(branch, base).reverse.each do |commit|
        history[:additions] <<  commit.additions
        history[:deletions] << -commit.deletions
      end

      history
    end

    # Returns a list of authors with the biggest impact on the repository, i.e.
    # changing the most code
    #
    # @param [String] branch The branch to load authors from
    # @param [Fixnum] count The number of authors to return
    # @raise [UnsupportedError] if the VCS does not support +:line_stats+
    # @return [Array<Actor>] An array of the given number of the most
    #         significant authors in the given branch
    def significant_authors(branch = self.class::DEFAULT_BRANCH, count = 3, base = nil)
      raise UnsupportedError unless supports? :line_stats

      authors = authors(branch, base).values.sort_by { |author| author.modifications }
      count = [count, authors.size].min
      authors[-count..-1].reverse
    end
    alias_method :significant_contributors, :significant_authors

    # Returns a list of commits with the biggest impact on the repository, i.e.
    # changing the most code
    #
    # @param [String] branch The branch to load commits from
    # @param [Fixnum] count The number of commits to return
    # @raise [UnsupportedError] if the VCS does not support +:line_stats+
    # @return [Array<Actor>] An array of the given number of the most
    #         significant commits in the given branch
    def significant_commits(branch = self.class::DEFAULT_BRANCH, count = 10, base = nil)
      raise UnsupportedError unless supports? :line_stats

      commits = commits(branch, base).sort_by { |commit| commit.modifications }
      count = [count, commits.size].min
      commits[-count..-1].reverse
    end

    # Returns a list of top contributors in the given branch
    #
    # This will first have to load all authors (and i.e. commits) from the
    # given branch.
    #
    # @param [String] branch The branch from which the top contributors should
    #        be retrieved
    # @param [Fixnum] count The number of contributors to return
    # @return [Array<Actor>] An array of the given number of top contributors
    #         in the given branch
    # @see #authors
    def top_authors(branch = self.class::DEFAULT_BRANCH, count = 3, base = nil)
      authors = authors(branch, base).values.sort_by { |author| author.commits.size }
      count = [count, authors.size].min
      authors[-count..-1].reverse
    end
    alias_method :top_contributors, :top_authors

    private

    # Loads all commits from the given branch and optionally compare them with
    # a base branch
    #
    # @abstract It has to be implemented by VCS specific subclasses
    # @param [String] branch The branch to load commits from
    # @param [String] base Only commits not contained in +base+ will be listed
    # @return [Array<Commit>] All commits from the given branch
    def load_commits(branch = nil, base = nil)
      raise NotImplementedError
    end

  end

end
