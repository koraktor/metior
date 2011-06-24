# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # Represents an actor in a source code repository
  #
  # Depending on the repository's VCS this may be for example an author or
  # committer.
  #
  # @abstract It has to be subclassed to implement a actor representation for a
  #           specific VCS.
  # @author Sebastian Staudt
  class Actor

    # @return [Fixnum] The lines of code that have been added by this actor
    attr_reader :additions

    # @return [Array<Commit>] The list of commits this actor has contributed to
    #         the source code repository
    attr_reader :commits

    # @return [Fixnum] The lines of code that have been deleted by this actor
    attr_reader :deletions

    # @return [String] The full name of the actor
    attr_reader :name

    # @return [String] A unqiue identifier for the actor
    attr_reader :id

    # Extracts a unique identifier from the given, VCS dependent actor object
    #
    # @abstract Different VCSs use different identifiers for users, so this
    #           method must be implemented for each supported VCS.
    # @param [Object] actor The actor object retrieved from the VCS
    # @return [String] A unique identifier for the given actor
    def self.id_for(actor)
      raise NotImplementedError
    end

    # Creates a new actor linked to the given source code repository
    #
    # @param [Repository] repo The repository this actor belongs to
    def initialize(repo)
      @additions = 0
      @commits   = []
      @deletions = 0
      @repo      = repo
    end

    # Adds a new commit to the list of commits this actor has contributed to
    # the analyzed source code repository
    #
    # @param [Commit] commit The commit to add to the list
    def add_commit(commit)
      @additions += commit.additions
      @commits << commit
      @deletions += commit.deletions
    end

    # Creates a string representation for this actor without recursing into
    # commit and repository details
    #
    # @return [String] A minimal string representation for this actor
    def inspect
      '#<%s:0x%x: @commits=%d @id="%s" @name="%s" @repo=<#%s:0x%x ...>>' %
        [
          self.class.name, __id__ * 2, @commits.size, @id, @name,
          @repo.class.name, @repo.__id__ * 2
        ]
    end

    # Returns the total of changed lines in all commits of this actor
    #
    # @return [Fixnum] The total number of changed lines
    def modifications
      additions + deletions
    end

  end

end
