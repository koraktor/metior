# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/commit'

module Metior

  module Git

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

        @additions      = commit.stats.additions
        @authored_date  = commit.authored_date
        @committed_date = commit.committed_date
        @deletions      = commit.stats.deletions
        @id             = commit.id
        @message        = commit.message
        @parents        = commit.parents.map { |parent| parent.id }

        @author = repo.actor commit.author
        @author.add_authored_commit self
        @committer = repo.actor commit.committer
        @committer.committed_commits << self

        @added_files    = []
        @modified_files = []
        @deleted_files  = []
        commit.diffs.each do |diff|
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

  end

end
