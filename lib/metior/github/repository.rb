# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'octokit'

require 'metior/github'
require 'metior/github/commit'
require 'metior/repository'

module Metior

  module GitHub

    # Represents a GitHub source code repository
    #
    # @author Sebastian Staudt
    class Repository < Metior::Repository

      include Metior::GitHub

      # @return [String] The project name of the repository
      attr_reader :project

      # @return [String] The GitHub username of the repository's owner
      attr_reader :user

      # Creates a new GitHub repository based on the given user and project
      # names
      #
      # @param [String] user The GitHub username of repository's owner
      # @param [String] project The name of the project
      def initialize(user, project)
        super "#{user}/#{project}"

        @project = project
        @user    = user
      end

      # Loads all commits including their authors from the given branch
      #
      # @note GitHub API is currently limited to 60 calls a minute, so you
      #       won't be able to query branches with more than 2100 commits
      #       (35 commits per call).
      # @param [String] branch The branch to load commits from
      # @return [Array<Commit>] All commits from the given branch
      def commits(branch = DEFAULT_BRANCH)
        if @commits[branch].nil?
          @authors[branch]    = {}
          @commits[branch]    = []
          @committers[branch] = {}
          load_commits(branch).each do |gh_commit|
            commit = Commit.new(self, branch, gh_commit)
            @commits[branch] << commit
            @authors[branch][commit.author.id]       = commit.author
            @committers[branch][commit.committer.id] = commit.committer
          end
        end

        @commits[branch]
      end

      # This method uses Octokit to load all commits from the given branch
      #
      # Because of GitHub API limitations, the commits have to be loaded in
      # batches.
      #
      # @param [String] branch The branch to load commits from
      # @return [Array<Commit>] All commits from the given branch
      # @see Octokit::Commits#commits
      def load_commits(branch)
        commits = []
        page = 1
        begin
          begin
            commits += Octokit.commits("#{@user}/#{@project}", branch, :page => page)
            page += 1
          end while true
        rescue Octokit::NotFound
        end
        commits
      end

    end

  end

end
