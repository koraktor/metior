# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'grit'

require 'metior/git'
require 'metior/git/commit'
require 'metior/repository'

module Metior

  module Git

    # Represents a Git source code repository
    #
    # @author Sebastian Staudt
    class Repository < Metior::Repository

      include Metior::Git

      # Creates a new Git repository based on the given path
      #
      # This creates a new +Grit::Repo+ instance to interface with the
      # repository.
      #
      # @param [String] path The file system path of the repository
      def initialize(path)
        super path
        
        @grit_repo = Grit::Repo.new(path)
      end

      # Loads all commits including their authors from the given branch
      #
      # @note Grit will choke on huge repositories, like Homebrew or the Linux
      #       kernel. You will have to raise the timeout limit using
      #       +Grit.git_timeout=+.
      # @param [String] branch The branch to load commits from
      # @return [Array<Commit>] All commits from the given branch
      def commits(branch = DEFAULT_BRANCH)
        if @commits[branch].nil?
          @authors[branch] = {}
          @commits[branch] = []
          load_commits(branch).each do |git_commit|
            commit = Commit.new(self, branch, git_commit)
            @commits[branch] << commit
            @authors[branch][commit.author.id] = commit.author
          end
        end

        @commits[branch]
      end

      private

      # This method uses Grit to load all commits from the given branch.
      #
      # Because of some Grit internal limitations, the commits have to be
      # loaded in batches of up to 500 commits.
      #
      # 
      # @param [String] branch The branch to load commits from
      # @return [Array<Commit>] All commits from the given branch
      # @see Grit::Repo#commits
      def load_commits(branch)
        commits = []
        skip = 0
        begin
          commits += @grit_repo.commits(branch, 500, skip)
          skip += 500
        end while commits.size == skip
        commits
      end

    end

  end

end
