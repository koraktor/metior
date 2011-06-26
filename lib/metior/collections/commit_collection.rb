# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/collections/actor_collection'
require 'metior/collections/collection'

module Metior

  # This class implements a collection of commits and provides functionality
  # specific to commits.
  #
  # @author Sebastian Staudt
  # @see Commit
  class CommitCollection < Collection

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
        authors << commit.author
      end
      authors
    end

    # Returns the list of commits that have been authored by the given authors
    #
    # @param [Array<Actor, Object>] author_ids One or more actual `Actor`
    #        instances or IDs of the authors that the commits should be
    #        filtered by
    # @return [CommitCollection] The commits that have been authored by the
    #         given authors
    def by(*author_ids)
      commits = CommitCollection.new
      author_ids.flatten.each do |author_id|
        author_id = author_id.id if author_id.is_a? Actor
        each_value do |commit|
          commits << commit if commit.author.id == author_id
        end
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
        committers << commit.committer
      end
      committers
    end

  end

end
