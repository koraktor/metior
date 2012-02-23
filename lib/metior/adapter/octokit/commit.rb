# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'time'

require 'metior/commit'

module Metior::Adapter::Octokit

  # Represents a commit in a GitHub source code repository
  #
  # @author Sebastian Staudt
  class Commit < Metior::Commit

    # Creates a new GitHub commit object linked to the repository and branch it
    # belongs to and the data parsed from the corresponding JSON data
    #
    # @param [Repository] repo The GitHub repository this commit belongs to
    # @param [Hashie:Mash] commit The commit data parsed from the JSON API
    def initialize(repo, commit)
      super repo

      @added_files    = []
      @additions      = 0
      @authored_date  = Time.parse commit.commit.author.date
      @committed_date = Time.parse commit.commit.committer.date
      @deleted_files  = []
      @deletions      = 0
      @id             = commit.sha
      @message        = commit.commit.message
      @modified_files = []
      @parents        = commit.parents.map { |parent| parent.sha }

      self.author    = commit.author.merge commit.commit.author
      self.committer = commit.committer.merge commit.commit.committer
    end

  end

end
