# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/actor'

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
      @authors  = {}
      @commits  = {}
      @path     = path
    end

    # Returns all authors from the given branch
    #
    # This will call +commits(branch)+ if the authors for the branch are not
    # known yet.
    #
    # @param [String] The branch from which the authors should be retrieved
    # @return [Array<Actor>] All authors from the given branch
    # @see #commits
    def authors(branch = vcs::DEFAULT_BRANCH)
      commits(branch) if @authors[branch].nil?
      @authors[branch]
    end

    # Loads all commits including their authors from the given branch
    #
    # @abstract It has to be implemented by VCS specific subclasses
    # @param [String] branch The branch to load commits from
    # @return [Array<Commit>] All commits from the given branch
    def commits(branch = vcs::DEFAULT_BRANCH)
    end

    # Returns a list of top contributors in the given branch
    #
    # This will first have to load all authors (and i.e. commits) from the
    # given branch.
    #
    # @param [String] The branch from which the top contributors should be
    #        retrieved
    # @param [Fixnum] The number of contributors to return
    # @return [Array<Actor>] An array of the given number of top contributors
    #         in the given branch
    # @see #authors
    def top_contributors(branch = vcs::DEFAULT_BRANCH, count = 3)
      authors = authors(branch).values.sort_by { |author| author.commits.size }
      count = [count, authors.size].min
      authors[-count..-1].reverse
    end

  end

end
