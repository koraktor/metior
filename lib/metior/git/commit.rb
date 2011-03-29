# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/commit'
require 'metior/git'
require 'metior/git/actor'

module Metior

  module Git

    # Represents a commit in a Git source code repository
    #
    # @author Sebastian Staudt
    class Commit < Metior::Commit

      include Metior::Git

      # Creates a new Git commit object linked to the repository and branch it
      # belongs to and the data from the corresponding +Grit::Commit+ object
      #
      # @param [Repository] repo The Git repository this commit belongs to
      # @param [String] branch The branch this commits belongs to
      # @param [Grit::Commit] commit The commit object from Grit
      def initialize(repo, branch, commit)
        super repo, branch

        authors = repo.authors(branch)
        author = authors[Actor.id_for commit.author]
        author = Actor.new repo, commit.author if author.nil?
        author.add_commit self

        @author         = author
        @authored_date  = commit.authored_date
        @committer      = Actor.new repo, commit.committer
        @committed_date = commit.committed_date
        @id             = commit.id
        @message        = commit.message
      end

    end

  end

end
