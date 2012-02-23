# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'grit'

require 'metior/repository'

module Metior::Adapter::Grit

  # Represents a Git source code repository
  #
  # @author Sebastian Staudt
  class Repository < Metior::Repository

    # Creates a new Git repository based on the given path
    #
    # This creates a new `Grit::Repo` instance to interface with the
    # repository.
    #
    # @param [String] path The file system path of the repository
    def initialize(path)
      super path

      @grit_repo = ::Grit::Repo.new(path)
    end

    # Returns the current branch of the repository
    #
    # This is the target ref of Git's HEAD, i.e. the currently checked out
    # branch. For a detached HEAD this may also be the commit ID of the checked
    # out commit.
    #
    # @see Grit::Repo#head
    def current_branch
      branch = @grit_repo.head
      return branch.name unless branch.nil?
      commit = @grit_repo.commit('HEAD')
      commit.id unless commit.nil?
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
      unless @refs.key? ref
        options = { :timeout => false }
        sha = @grit_repo.git.native(:rev_parse, options, "#{ref}^{}")
        @refs[ref] = sha.rstrip
      end
      @refs[ref]
    end

    # Loads the line stats for the commits given by a set of commit IDs
    #
    # @param [Array<String>] ids The IDs of the commits to load line stats for
    # @return [Hash<String, Array<Fixnum>] An array of two number (line
    #         additions and deletions) for each of the given commit IDs
    def load_line_stats(ids)
      if ids.is_a? Range
        if ids.first == ''
          range = ids.last
        else
          range = '%s..%s' % [ids.first, ids.last]
        end

        options = { :numstat => true, :timeout => false }
        output = @grit_repo.git.native :log, options, range
        commit_stats = ::Grit::CommitStats.list_from_string @grit_repo, output
      else
        commit_stats = []
        ids.each_slice(500) do |id_slice|
          options = { :numstat => true, :timeout => false }
          output = @grit_repo.git.native :log, options, *id_slice
          commit_stats += ::Grit::CommitStats.list_from_string @grit_repo, output
        end
      end

      Hash[commit_stats.map do |stats|
        [stats.first, [stats.last.additions, stats.last.deletions]]
      end]
    end

    # Retrieves a raw commit object for the given commit ID
    #
    # @param [String] id The ID of the commit
    # @return [Grit::Commit] The commit object
    # @see Grit::Repo#commit
    def raw_commit(id)
      @grit_repo.commit(id)
    end

    private

    # Loads all branches and the corresponding commit IDs of this repository
    #
    # @return [Hash<String, String>] The names of all branches and the
    #         corresponding commit IDs
    # @see Grit::Repo#branches
    def load_branches
      Hash[@grit_repo.branches.map { |b| [b.name, b.commit.id] }]
    end

    # This method uses Grit to load all commits from the given commit range
    #
    # Because of some Grit internal limitations, the commits have to be loaded
    # in batches of up to 300 commits.
    #
    # @note Grit will choke on huge repositories, like Homebrew or the Linux
    #       kernel. You will have to raise the timeout limit using
    #       `Grit.git_timeout=`.
    # @param [String, Range] range The range of commits for which the commits
    #        should be loaded. This may be given as a string
    #        (`'master..development'`), a range (`'master'..'development'`)
    #        or as a single ref (`'master'`). A single ref name means all
    #        commits reachable from that ref.
    # @return [Grit::Commit, nil] The base commit of the requested range or
    #         `nil` if the the range starts at the beginning of the history
    # @return [Array<Grit::Commit>] All commits in the given commit range
    # @see Grit::Repo#commits
    def load_commits(range)
      if range.first == ''
        base_commit = nil
        range = range.last
      else
        base_commit = @grit_repo.commit(range.first)
        range = '%s..%s' % [range.first, range.last]
      end

      options = { :pretty => 'raw', :timeout => false }
      output = @grit_repo.git.native :rev_list, options, range
      commits = ::Grit::Commit.list_from_string @grit_repo, output

      [base_commit, commits]
    end

    # Loads both the name and description of the project contained in the
    # repository from the description file in `GIT_DIR`. The first line of that
    # file is used as the project's name, the remaining text is used as a
    # description of the project.
    #
    # @see #description
    # @see #name
    # @see Grit::Repo#name
    def load_name_and_description
      description = @grit_repo.description
      if description.start_with? 'Unnamed repository'
        @name        = ''
        @description = ''
      else
        description  = description.lines.to_a
        @name        = description.shift.strip
        @description = description.join("\n").strip
      end
    end
    alias_method :load_description, :load_name_and_description
    alias_method :load_name, :load_name_and_description

    # Loads all tags and the corresponding commit IDs of this repository
    #
    # @return [Hash<String, String>] The names of all tags and the
    #         corresponding commit IDs
    # @see Grit::Repo#tags
    def load_tags
      Hash[@grit_repo.tags.map { |b| [b.name, b.commit.id] }]
    end

  end

end
