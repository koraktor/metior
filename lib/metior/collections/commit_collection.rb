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

    # Returns the commits in this collection that have been committed after the
    # given time
    #
    # @param [Time, Date, DateTime, String] date The time to use as the lower
    #        limit to filter the commits
    # @return [CommitCollection] The commits that have been committed after the
    #         given date
    def after(date)
      date = Time.parse date if date.is_a? String
      commits = CommitCollection.new
      each_value do |commit|
        commits << commit if commit.committed_date > date
      end
      commits
    end

    # Returns the authors of all or a specific commit in this collection
    #
    # @param [Object] commit_id The ID of the commit, if only the author of a
    #        specific commit should be returned
    # @return [ActorCollection] All authors of the commits in this collection
    #         or the author of a specific commit
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
    def before(date)
      date = Time.parse date if date.is_a? String
      commits = CommitCollection.new
      each_value do |commit|
        commits << commit if commit.committed_date < date
      end
      commits
    end

    # Returns the list of commits that have been authored by the given authors
    #
    # @param [Array<Actor, Object>] author_ids One or more actual `Actor`
    #        instances or IDs of the authors that the commits should be
    #        filtered by
    # @return [CommitCollection] The commits that have been authored by the
    #         given authors
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

    # Returns the committers of all or a specific commit in this collection
    #
    # @param [Object] commit_id The ID of the commit, if only the committer of
    #        a specific commit should be returned
    # @return [ActorCollection] All committers of the commits in this
    #         collection or the committer of a specific commit
    def committers(commit_id = nil)
      committers = ActorCollection.new
      if commit_id.nil?
        each_value { |commit| committers << commit.committer }
      elsif key? commit_id
        committers << self[commit_id].committer
      end
      committers
    end

  end

end
