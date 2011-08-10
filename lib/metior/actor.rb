# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/auto_include_vcs'

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

    include AutoIncludeVCS

    # @return [CommitCollection] The list of commits this actor has contributed
    #         to the source code repository
    attr_reader :authored_commits
    alias_method :commits, :authored_commits

    # @return [CommitCollection] The list of commits this actor has committed
    #         to the source code repository
    attr_reader :committed_commits

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
      @authored_commits  = CommitCollection.new
      @committed_commits = CommitCollection.new
      @repo              = repo
    end

    # Returns the lines of code that have been added by this actor
    #
    # @return [Fixnum] The lines of code that have been added
    def additions
      @authored_commits.additions
    end

    # Returns the lines of code that have been deleted by this actor
    #
    # @return [Fixnum] The lines of code that have been deleted
    def deletions
      @authored_commits.deletions
    end

    # Creates a string representation for this actor without recursing into
    # commit and repository details
    #
    # @return [String] A minimal string representation for this actor
    def inspect
      '#<%s:0x%x: @commits=%d @id="%s" @name="%s" @repo="%s"' %
        [
          self.class.name, __id__ * 2, @authored_commits.size, @id, @name,
          @repo.path
        ]
    end

    # Returns the total of changed lines in all commits of this actor
    #
    # @return [Fixnum] The total number of changed lines
    def modifications
      @authored_commits.modifications
    end

  end

end
