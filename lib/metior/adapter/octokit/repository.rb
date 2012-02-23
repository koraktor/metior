# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'octokit'

require 'metior/repository'

module Metior::Adapter::Octokit

  # Represents a GitHub source code repository
  #
  # @author Sebastian Staudt
  class Repository < Metior::Repository

    # @return [String] The project name of the repository
    attr_reader :project

    # @return [String] The GitHub username of the repository's owner
    attr_reader :user

    # Creates a new GitHub repository based on the given user and project names
    #
    # @param [String] user The GitHub username of repository's owner
    # @param [String] project The name of the project
    def initialize(user, project = nil)
      user, project = user.split('/') if user.include? '/'

      super "#{user}/#{project}"

      @project     = project
      @user        = user
    end

    # Returns the current branch of the repository
    #
    # There's no information about the default branch of a repository in the
    # GitHub API v2 which is supported by Octokit. So we just return `'master'`
    # here.
    #
    # @return ['master'] Always `'master'`
    def current_branch
      'master'
    end

    # Returns the unique identifier for the commit the given reference – like a
    # branch name – is pointing to
    #
    # Returns the given ref name immediately if it is a full SHA1 commit ID.
    #
    # @param [String] ref A symbolic reference name
    # @return [String] The SHA1 ID of the commit the reference is pointing to
    def id_for_ref(ref)
      return ref if ref.match(/[0-9a-f]{40}/)
      @refs[ref] = ::Octokit.commit(@path, ref).sha unless @refs.key? ref
      @refs[ref]
    end

    private

    # Loads all branches and the corresponding commit IDs of this repository
    #
    # @return [Hash<String, String>] The names of all branches and the
    #         corresponding commit IDs
    # @see Octokit#branches
    def load_branches
      ::Octokit.branches(@path)
    end

    # This method uses Octokit to load all commits from the given commit range
    #
    # @note GitHub API is currently limited to 60 calls a minute, so you won't
    #       be able to query branches with more than 2100 commits (35 commits
    #       per call).
    # @param [String, Range] range The range of commits for which the commits
    #        should be loaded. This may be given as a string
    #        (`'master..development'`), a range (`'master'..'development'`)
    #        or as a single ref (`'master'`). A single ref name means all
    #        commits reachable from that ref.
    # @return [Hashie::Mash, nil] The base commit of the requested range or
    #         `nil` if the the range starts at the beginning of the history
    # @return [Array<Hashie::Mash>] All commits in the given commit range
    # @see Octokit::Commits#commits
    def load_commits(range)
      base_commit = nil
      commits = []
      last_commit = nil
      loop do
        new_commits = ::Octokit.commits(@path, nil, :last_sha => last_commit, :per_page => 100, :top => range.last)
        break if new_commits.empty?

        base_commit_index = new_commits.find_index do |commit|
          commit.sha == range.first
        end unless range.first == ''
        unless base_commit_index.nil?
          if base_commit_index > 0
            commits += new_commits[0..base_commit_index-1]
          end
          base_commit = new_commits[base_commit_index]
          break
        end
        commits += new_commits
        last_commit = new_commits.last.sha
      end

      [base_commit, commits]
    end

    # Loads both the name and description of the project contained in the
    # repository from GitHub
    #
    # @see #description
    # @see #name
    # @see Octokit.repo
    def load_name_and_description
      github_repo  = ::Octokit.repo @path
      @description = github_repo.description
      @name        = github_repo.name
    end
    alias_method :load_description, :load_name_and_description
    alias_method :load_name, :load_name_and_description

    # Loads all tags and the corresponding commit IDs of this repository
    #
    # @return [Hash<String, String>] The names of all tags and the
    #         corresponding commit IDs
    # @see Octokit#tags
    def load_tags
      ::Octokit.tags @path
    end

  end

end
