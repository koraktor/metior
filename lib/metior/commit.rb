# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # This class represents a commit in a source code repository
  #
  # Although not all VCSs distinguish authors from committers this
  # implementation forces a differentiation between the both.
  #
  # @abstract It has to be subclassed to implement a commit representation for
  #           a specific VCS.
  # @author Sebastian Staudt
  class Commit

    # @return [Array<String>] A list of file paths added in this commit
    attr_reader :added_files

    # @return [Fixnum] The lines of code that have been added in this commit
    attr_reader :additions

    # @return [Actor] This commit's author
    attr_reader :author

    # @return [Time] The date this commit has been authored
    attr_reader :authored_date

    # @return [String] The branch this commit belongs to
    attr_reader :branch

    # @return [Time] The date this commit has been committed
    attr_reader :committed_date

    # @return [Actor] This commit's committer
    attr_reader :committer

    # @return [Array<String>] A list of file paths deleted in this commit
    attr_reader :deleted_files

    # @return [Fixnum] The lines of code that have been deleted in this commit
    attr_reader :deletions

    # @return [String] The commit message of this commit
    attr_reader :message

    # @return [Array<String>] A list of file paths modified in this commit
    attr_reader :modified_files

    # @return [Repository] The repository this commit belongs to
    attr_reader :repo

    # Calculate some predefined activity statistics for the given set of
    # commits
    #
    # @param [Array<Commit>] commits The commits to analyze
    # @return [Hash<Symbol, Object>] The calculated statistics for the commits
    def self.activity(commits)
      activity = {}

      commit_count = commits.size

      active_days = {}
      commits.each do |commit|
        date = commit.committed_date.utc
        day  = Time.utc(date.year, date.month, date.day)
        if active_days.key? day
          active_days[day] += 1
        else
          active_days[day] = 1
        end
      end

      most_active_day = active_days.sort_by { |day, count| count }.last.first

      activity[:first_commit_date] = commits.last.committed_date
      activity[:last_commit_date]  = commits.first.committed_date

      age_in_days = (Time.now - activity[:first_commit_date]) / 86400.0

      activity[:active_days]            = active_days
      activity[:most_active_day]        = most_active_day
      activity[:commits_per_day]        = commit_count / age_in_days
      activity[:commits_per_active_day] = commit_count.to_f / active_days.size

      activity
    end

    # Creates a new commit instance linked to the given repository and branch
    #
    # @param [Repository] repo The repository this commit belongs to
    # @param [String] branch The branch this commit belongs to
    def initialize(repo, branch)
      @repo   = repo
      @branch = branch
    end

    # Returns the total of changed lines in this commit
    #
    # @return [Fixnum] The total number of changed lines
    def modifications
      additions + deletions
    end

    # Returns the subject line of the commit message, i.e. the first line
    #
    # @return [String] The subject of the commit
    def subject
      @message.split(/$/).first
    end

  end

end
