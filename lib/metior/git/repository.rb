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
      # This creates a new `Grit::Repo` instance to interface with the
      # repository.
      #
      # @param [String] path The file system path of the repository
      def initialize(path)
        super path

        @grit_repo = Grit::Repo.new(path)
      end

      # Returns the names of all branches of this repository
      #
      # @return [Array<String>] The names of all branches
      # @see Grit::Repo#branches
      def branches
        @grit_repo.branches.map { |branch| branch.name }
      end

      private

      # Returns the unique identifier for the commit the given reference – like
      # a branch name – is pointing to
      #
      # Returns the given ref name immediately if it is a full SHA1 commit ID.
      #
      # @param [String] ref A symbolic reference name
      # @return [String] The SHA1 ID of the commit the reference is pointing to
      def id_for_ref(ref)
        return ref if ref.match /[0-9a-f]{40}/
        unless @refs.key? ref
          @refs[ref] = @grit_repo.git.rev_parse({}, "#{ref}^{}")
        end
        @refs[ref]
      end

      # This method uses Grit to load all commits from the given commit range
      #
      # Because of some Grit internal limitations, the commits have to be
      # loaded in batches of up to 500 commits.
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

        commits = []
        skip = 0
        begin
          commits += @grit_repo.commits(range, 500, skip)
          skip += 500
        end while commits.size == skip

        [base_commit, commits]
      end

    end

  end

end
