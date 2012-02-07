# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

module Metior::Adapter::Octokit

  # Represents an actor in a GitHub source code repository, i.e. an author or
  # committer.
  #
  # @author Sebastian Staudt
  class Actor < Metior::Actor

    alias_method :login, :id

    # Returns the GitHub login as an identifier for the given actor.
    #
    # @param [Hashie::Mash] actor The actor's data parsed from the JSON API
    # @return [String] The GitHub login of the given actor
    def self.id_for(actor)
      actor.login
    end

    # Creates a new actor instance
    #
    # @param [Repository] repo The repository this actor belongs to
    # @param [Hashie::Mash] actor The actor's data parsed from the JSON API
    def initialize(repo, actor)
      super repo
      @email = actor.email
      @id    = actor.login
      @name  = actor.name
    end

  end

end
