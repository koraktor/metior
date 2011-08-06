# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/auto_include_vcs'

module Metior

  # This class represents a commit in a source code repository
  #
  # Although not all VCSs distinguish authors from committers this
  # implementation forces a differentiation between the both.
  #
  # @abstract It has to be subclassed to implement a commit representation for
  #           a specific VCS.
  # @author Sebastian Staudt
  class Commit

    include AutoIncludeVCS

    # @return [Array<String>] A list of file paths added in this commit
    attr_reader :added_files

    # @return [Fixnum] The lines of code that have been added in this commit
    attr_reader :additions

    # @return [Actor] This commit's author
    attr_reader :author

    # @return [Time] The date this commit has been authored
    attr_reader :authored_date

    # @return [Object] A unique identifier of the commit in the repository
    attr_reader :id

    # @return [Array<Object>] The unique identifiers of the children of this
    #         commit
    attr_reader :children

    # @return [Time] The date this commit has been committed
    attr_reader :committed_date

    # @return [Actor] This commit's committer
    attr_reader :committer

    # @return [Array<String>] A list of file paths deleted in this commit
    attr_reader :deleted_files

    # @return [Fixnum] The lines of code that have been deleted in this commit
    attr_reader :deletions

    # @return [String] The commit message of this commit
    attr_reader :message

    # @return [Array<String>] A list of file paths modified in this commit
    attr_reader :modified_files

    # @return [Array<Object>] The unique identifiers of one or more more
    #         parents of this commit
    attr_reader :parents

    # @return [Repository] The repository this commit belongs to
    attr_reader :repo

    # Creates a new commit instance linked to the given repository and branch
    #
    # @param [Repository] repo The repository this commit belongs to
    def initialize(repo)
      @children = []
      @repo     = repo
    end

    # Sets the author of this commit
    #
    # This also adds the commit to the commits this actor has authored.
    #
    # @param [Object] author The data of the author of this commit
    # @see Actor#authored_commits
    # @see Repository#actor
    def author=(author)
      @author = @repo.actor author
      @author.authored_commits << self
    end

    # Adds the unique identifier of a child of this commit to the list of child
    # commits
    #
    # @param [Object] child The unique identifier of the child commit to add
    def add_child(child)
      @children << child
    end

    # Sets the comitter of this commit
    #
    # This also adds the commit to the commits this actor has comitted.
    #
    # @param [Object] committer The data of the comitter of this commit
    # @see Actor#committed_commits
    # @see Repository#actor
    def committer=(committer)
      @committer = @repo.actor committer
      @committer.committed_commits << self
    end

    # Returns whether this commits is a merge commit
    #
    # @return [Boolean] `true` if this commit is a merge commit
    def merge?
      @parents.size > 1
    end

    # Returns the total of changed lines in this commit
    #
    # @return [Fixnum] The total number of changed lines
    def modifications
      additions + deletions
    end

    # Returns the subject line of the commit message, i.e. the first line
    #
    # @return [String] The subject of the commit
    def subject
      @message.split(/$/).first
    end

    # Creates a string representation for this commit without recursing into
    # actor and repository details
    #
    # @return [String] A minimal string representation for this commit
    def inspect
      '#<%s:0x%x: @author="%s" @committer="%s" @id="%s" @repo="%s" @subject="%s">' %
        [
          self.class.name, __id__ * 2, @author.id, @committer.id, @id,
          @repo.path, subject
        ]
    end

  end

end
