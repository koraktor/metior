# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Git

  # Represents a commit in a Git source code repository
  #
  # @author Sebastian Staudt
  class Commit < Metior::Commit

    # Creates a new Git commit object linked to the repository and branch it
    # belongs to and the data from the corresponding `Grit::Commit` object
    #
    # @param [Repository] repo The Git repository this commit belongs to
    # @param [Grit::Commit] commit The commit object from Grit
    def initialize(repo, commit)
      super repo

      @authored_date  = commit.authored_date
      @committed_date = commit.committed_date
      @id             = commit.id
      @message        = commit.message
      @parents        = commit.parents.map { |parent| parent.id }

      self.author    = commit.author
      self.committer = commit.committer
    end

  end

  # Loads the file stats for this commit from the repository
  #
  # @see Repository#raw_commit
  def load_file_stats
    @added_files    = []
    @modified_files = []
    @deleted_files  = []
    @repo.raw_commit(@id).diffs.each do |diff|
      if diff.new_file
        @added_files    << diff.b_path
      elsif diff.deleted_file
        @deleted_files  << diff.b_path
      elsif diff.renamed_file
        @added_files    << diff.b_path
        @deleted_files  << diff.a_path
      else
        @modified_files << diff.b_path
      end
    end
  end

end
