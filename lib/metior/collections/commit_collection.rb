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
        each_value do |commit|
          authors[commit.author.id] = commit.author
        end
      elsif key? commit_id
        author = commit.author
        authors[author.id] = author
      end
      authors
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
        each_value do |commit|
          committers[commit.committer.id] = commit.committer
        end
      elsif key? commit_id
        committer = commit.committer
        committers[committer.id] = committer
      end
      committers
    end

  end

end
