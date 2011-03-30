# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

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

    # @return [Fixnum] The lines of code that have been added in this commit
    attr_reader :additions

    # @return [Actor] This commit's author
    attr_reader :author

    # @return [Time] The date this commit has been authored
    attr_reader :authored_date

    # @return [String] The branch this commit belongs to
    attr_reader :branch

    # @return [Time] The date this commit has been committed
    attr_reader :committed_date

    # @return [Actor] This commit's committer
    attr_reader :committer

    # @return [Fixnum] The lines of code that have been deleted in this commit
    attr_reader :deletions

    # @return [String] The commit message of this commit
    attr_reader :message

    # @return [Repository] The repository this commit belongs to
    attr_reader :repo

    # Creates a new commit instance linked to the given repository and branch
    #
    # @param [Repository] repo The repository this commit belongs to
    # @param [String] branch The branch this commit belongs to
    def initialize(repo, branch)
      @repo   = repo
      @branch = branch
    end

    # Returns the total of changed lines in this commit
    #
    # @return [Fixnum] The total number of changed lines
    def modifications
      additions + deletions
    end

  end

end
