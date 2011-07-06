# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'time'

require 'metior/collections/actor_collection'
require 'metior/collections/collection'

module Metior

  # This class implements a collection of commits and provides functionality
  # specific to commits.
  #
  # @author Sebastian Staudt
  # @see Commit
  class CommitCollection < Collection

    # Calculate some predefined activity statistics for the commits in this
    # collection
    #
    # @return [Hash<Symbol, Object>] The calculated statistics for the commits
    #         in this collection
    # @see Commit#committed_date
    def activity
      activity = {}
      commit_count = values.size

      active_days = {}
      values.each do |commit|
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
      each_value do |commit|
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
        each_value { |commit| authors << commit.author }
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
      each_value do |commit|
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
      each_value do |commit|
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
      first.support! :file_stats

      commits = CommitCollection.new
      each_value do |commit|
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
        each_value { |commit| committers << commit.committer }
      elsif key? commit_id
        committers << self[commit_id].committer
      end
      committers
    end

    # Returns the given number of commits with most line changes on the
    # repository
    #
    # @param [Numeric] count The number of commits to return
    # @return [CommitCollection] The given number of commits ordered by impact
    # @see Commit#modifications
    def most_significant(count = 10)
      first.support! :line_stats

      commits = CommitCollection.new
      values.sort_by { |commit| -commit.modifications }.each do |commit|
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
      first.support! :line_stats

      commits = CommitCollection.new
      each_value do |commit|
        commits << commit if commit.modifications >= line_count
      end
      commits
    end

  end

end
