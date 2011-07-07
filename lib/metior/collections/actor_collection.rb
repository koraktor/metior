# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/collections/collection'
require 'metior/collections/commit_collection'

module Metior

  # This class implements a collection of actors and provides functionality
  # specific to actors.
  #
  # @author Sebastian Staudt
  # @see Actor
  class ActorCollection < Collection

    # Returns the commits of all or a specific actor in this collection
    #
    # @param [Object] actor_id The ID of the actor, if only the commits of a
    #        specific actor should be returned
    # @return [CommitCollection] All commits of the actors in this collection
    #         or of a specific actor
    def commits(actor_id = nil)
      commits = CommitCollection.new
      if actor_id.nil?
        each { |actor| commits.merge! actor.commits }
      elsif key? actor_id
        commits = self[actor_id].commits
      end
      commits
    end

    # Returns up to the given number of actors in this collection with the
    # biggest impact on the repository, i.e. changing the most code
    #
    # @param [Numeric] count The number of actors to return
    # @return [ActorCollection] The given number of actors ordered by impact
    # @see Actor#modifications
    def most_significant(count = 3)
      first.support! :line_stats

      authors = ActorCollection.new
      sort_by { |author| -author.modifications }.each do |author|
        authors << author
        break if authors.size == count
      end
      authors
    end

    # Returns up to the given number of actors in this collection with the
    # most commits
    #
    # @param [Numeric] count The number of actors to return
    # @return [ActorCollection] The given number of actors ordered by commit
    #         count
    # @see Actor#commits
    def top(count = 3)
      authors = ActorCollection.new
      sort_by { |author| -author.commits.size }.each do |author|
        authors << author
        break if authors.size == count
      end
      authors
    end

  end

end
