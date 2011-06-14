# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'time'

require 'metior/commit'
require 'metior/github'
require 'metior/github/actor'
require 'time'

module Metior

  module GitHub

    # Represents a commit in a GitHub source code repository
    #
    # @author Sebastian Staudt
    class Commit < Metior::Commit

      include Metior::GitHub

      # Creates a new GitHub commit object linked to the repository and branch
      # it belongs to and the data parsed from the corresponding JSON data
      #
      # @param [Repository] repo The GitHub repository this commit belongs to
      # @param [String] range The commit range this commits belongs to
      # @param [Hashie:Mash] commit The commit data parsed from the JSON API
      def initialize(repo, range, commit)
        super repo, range

        @added_files    = []
        @additions      = 0
        @authored_date  = Time.parse commit.authored_date
        @committed_date = Time.parse commit.committed_date
        @deleted_files  = []
        @deletions      = 0
        @id             = commit.id
        @message        = commit.message
        @modified_files = []

        authors = repo.authors range
        @author = authors[Actor.id_for commit.author]
        @author = Actor.new repo, commit.author if author.nil?
        @author.add_commit self

        committers = repo.committers range
        @committer = committers[Actor.id_for commit.committer]
        @committer = Actor.new repo, commit.committer if @committer.nil?
        @committer.add_commit self
      end

    end

  end

end
