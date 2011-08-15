# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'time'

require 'metior/actor'
require 'metior/collections/actor_collection'
require 'metior/collections/collection'

module Metior

  # This class implements a collection of commits and provides functionality
  # specific to commits.
  #
  # @author Sebastian Staudt
  # @see Commit
  class CommitCollection < Collection

    # Creates a new collection with the given commits
    #
    # @param [Array<Commit>] commits The commits that should be initially
    #        inserted into the collection
    def initialize(commits = [])
      @additions = nil
      @deletions = nil

      super
    end

    # Adds a commit to this collection
    #
    # @param [Commit] commit The commit to add to this collection
    # @return [CommitCollection] The collection itself
    def <<(commit)
      return self if key? commit.id

      unless @additions.nil?
        @additions += commit.additions
        @deletions += commit.deletions
      end

      super
    end

    # Calculate some predefined activity statistics for the commits in this
    # collection
    #
    # @return [Hash<Symbol, Object>] The calculated statistics for the commits
    #         in this collection
    # @see Commit#committed_date
    def activity
      activity = {}
      return activity if empty?

      commit_count = values.size

      active_days = {}
      each do |commit|
        date = commit.committed_date.utc
        day  = Time.utc(date.year, date.month, date.day)
        if active_days.key? day
          active_days[day] += 1
        else
          active_days[day] = 1
        end
      end

      most_active_day = active_days.sort_by { |day, count| count }.last.first

      activity[:first_commit_date] = last.committed_date
      activity[:last_commit_date]  = first.committed_date

      age_in_days = (Time.now - activity[:first_commit_date]) / 86400.0

      activity[:active_days]            = active_days
      activity[:most_active_day]        = most_active_day
      activity[:commits_per_day]        = commit_count / age_in_days
      activity[:commits_per_active_day] = commit_count.to_f / active_days.size

      activity
    end

    # Returns the lines of code that have been added by the commits in this
    # collection
    #
    # This will load the line stats from the commits if not done yet.
    #
    # @return [Fixnum] The lines of code that have been added
    # @see #load_line_stats
    def additions
      support! :line_stats

      load_line_stats if @additions.nil?
      @additions
    end

    # Returns the commits in this collection that have been committed after the
    # given time
    #
    # @param [Time, Date, DateTime, String] date The time to use as the lower
    #        limit to filter the commits
    # @return [CommitCollection] The commits that have been committed after the
    #         given date
    # @see Commit#committed_date
    # @see Time.parse
    def after(date)
      date = Time.parse date if date.is_a? String
      commits = CommitCollection.new
      each do |commit|
        commits << commit if commit.committed_date > date
      end
      commits
    end
    alias_method :newer, :after

    # Returns the authors of all or a specific commit in this collection
    #
    # @param [Object] commit_id The ID of the commit, if only the author of a
    #        specific commit should be returned
    # @return [ActorCollection] All authors of the commits in this collection
    #         or the author of a specific commit
    # @see Commit#author
    def authors(commit_id = nil)
      authors = ActorCollection.new
      if commit_id.nil?
        each { |commit| authors << commit.author }
      elsif key? commit_id
        authors << self[commit_id].author
      end
      authors
    end

    # Returns the commits in this collection that have been committed before
    # the given time
    #
    # @param [Time, Date, DateTime, String] date The time to use as the upper
    #        limit to filter the commits
    # @return [CommitCollection] The commits that have been committed after the
    #         given date
    # @see Commit#committed_date
    # @see Time.parse
    def before(date)
      date = Time.parse date if date.is_a? String
      commits = CommitCollection.new
      each do |commit|
        commits << commit if commit.committed_date < date
      end
      commits
    end
    alias_method :older, :before

    # Returns the list of commits that have been authored by the given authors
    #
    # @param [Array<Actor, Object>] author_ids One or more actual `Actor`
    #        instances or IDs of the authors that the commits should be
    #        filtered by
    # @return [CommitCollection] The commits that have been authored by the
    #         given authors
    # @see Commit#author
    def by(*author_ids)
      author_ids = author_ids.flatten.map do |author_id|
        author_id.is_a?(Actor) ? author_id.id : author_id
      end
      commits = CommitCollection.new
      each do |commit|
        commits << commit if author_ids.include? commit.author.id
      end
      commits
    end

    # Returns the commits in this collection that change any of the given files
    #
    # @param [Array<String>] files The path of the files to filter commits by
    # @return [CommitCollection] The commits that contain changes to the given
    #         files
    # @see Commit#added_files
    # @see Commit#deleted_files
    # @see Commit#modified_files
    def changing(*files)
      support! :file_stats

      commits = CommitCollection.new
      each do |commit|
        commit_files = commit.added_files + commit.deleted_files + commit.modified_files
        commits << commit unless (commit_files & files).empty?
      end
      commits
    end
    alias_method :touching, :changing

    # Returns the committers of all or a specific commit in this collection
    #
    # @param [Object] commit_id The ID of the commit, if only the committer of
    #        a specific commit should be returned
    # @return [ActorCollection] All committers of the commits in this
    #         collection or the committer of a specific commit
    # @see Commit#committer
    def committers(commit_id = nil)
      committers = ActorCollection.new
      if commit_id.nil?
        each { |commit| committers << commit.committer }
      elsif key? commit_id
        committers << self[commit_id].committer
      end
      committers
    end

    # Returns the lines of code that have been deleted by the commits in this
    # collection
    #
    # This will load the line stats from the commits if not done yet.
    #
    # @return [Fixnum] The lines of code that have been deleted
    # @see #load_line_stats
    def deletions
      support! :line_stats

      load_line_stats if @deletions.nil?
      @deletions
    end

    # This evaluates the changed lines in each commit of this collection
    #
    # For easier use, the values are stored in separate arrays where each
    # number represents the number of changed (i.e. added or deleted) lines in
    # one commit.
    #
    # @example
    #  commits.line_history
    #  => { :additions => [10, 5, 0], :deletions => [0, -2, -1] }
    # @return [Hash<Symbol, Array>] Added lines are returned in an `Array`
    #         assigned to key `:additions`, deleted lines are assigned to
    #         `:deletions`
    # @see Commit#additions
    # @see Commit#deletions
    def line_history
      support! :line_stats

      history = { :additions => [], :deletions => [] }
      values.reverse.each do |commit|
        history[:additions] <<  commit.additions
        history[:deletions] << -commit.deletions
      end

      history
    end

    # Returns the total of lines changed by the commits in this collection
    #
    # @return [Fixnum] The total number of lines changed
    # @see #additions
    # @see #deletions
    def modifications
      additions + deletions
    end

    # Returns the given number of commits with most line changes on the
    # repository
    #
    # @param [Numeric] count The number of commits to return
    # @return [CommitCollection] The given number of commits ordered by impact
    # @see Commit#modifications
    def most_significant(count = 10)
      support! :line_stats

      commits = CommitCollection.new
      sort_by { |commit| -commit.modifications }.each do |commit|
        commits << commit
        break if commits.size == count
      end
      commits
    end
    alias_method :top, :most_significant

    # Returns the commits in this collection that change at least the given
    # number of lines
    #
    # @param [Numeric] line_count The number of lines that should be
    #        changed at least by the commits
    # @return [CommitCollection] The commits that change at least the given
    #         number of lines
    # @see Commit#modifications
    def with_impact(line_count)
      support! :line_stats

      commits = CommitCollection.new
      each do |commit|
        commits << commit if commit.modifications >= line_count
      end
      commits
    end

    private

    # Loads the line stats for all commits in this collection
    #
    # @see Commit#additions
    # @see Commit#deletions
    def load_line_stats
      @additions = 0
      @deletions = 0
      each do |commit|
        @additions += commit.additions
        @deletions += commit.deletions
      end
    end

  end

end
