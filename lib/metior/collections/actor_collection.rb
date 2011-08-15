# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # This class implements a collection of actors and provides functionality
  # specific to actors.
  #
  # @author Sebastian Staudt
  # @see Actor
  class ActorCollection < Collection

    # Returns the commits authored by all or a specific actor in this
    # collection
    #
    # @param [Object] actor_id The ID of the actor, if only the commits of a
    #        specific actor should be returned
    # @return [CommitCollection] All commits authored by the actors in this
    #         collection or by a specific actor
    def authored_commits(actor_id = nil)
      load_commits :authored_commits, actor_id
    end
    alias_method :commits, :authored_commits

    # Returns the commits committed by all or a specific actor in this
    # collection
    #
    # @param [Object] actor_id The ID of the actor, if only the commits of a
    #        specific actor should be returned
    # @return [CommitCollection] All commits committed by the actors in this
    #         collection or by a specific actor
    def committed_commits(actor_id = nil)
      load_commits :committed_commits, actor_id
    end

    # Returns up to the given number of actors in this collection with the
    # biggest impact on the repository, i.e. changing the most code
    #
    # @param [Numeric] count The number of actors to return
    # @return [ActorCollection] The given number of actors ordered by impact
    # @see Actor#modifications
    def most_significant(count = 3)
      support! :line_stats

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
      sort_by { |author| -author.authored_commits.size }.each do |author|
        authors << author
        break if authors.size == count
      end
      authors
    end

    private

    # Loads the commits authored or committed by all actors in this collection
    # or a specific actor
    #
    # @param [:authored_commits, :committed_commits] commit_type The type of
    #        commits to load
    # @param [Object] actor_id The ID of the actor, if only the commits of a
    #        specific actor should be returned
    # @return [CommitCollection] All commits authored or committed by the
    #         actors in this collection or by a specific actor
    def load_commits(commit_type, actor_id = nil)
      commits = CommitCollection.new
      if actor_id.nil?
        each { |actor| commits.merge! actor.send(commit_type) }
      elsif key? actor_id
        commits = self[actor_id].send commit_type
      end
      commits
    end

  end

end
