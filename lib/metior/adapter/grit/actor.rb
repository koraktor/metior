# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

module Metior::Adapter::Grit

  # Represents an actor in a Git source code repository, i.e. an author or
  # committer.
  #
  # @author Sebastian Staudt
  class Actor < Metior::Actor

    alias_method :email, :id

    # Returns the email address as an identifier for the given actor.
    #
    # Git uses email addresses as identifiers for its actors.
    #
    # @param [Grit::Actor] actor The actor object from Grit
    # @return [String] The email address of the given actor
    def self.id_for(actor)
      actor.email
    end

    # Creates a new actor instance
    #
    # @param [Repository] repo The repository this actor belongs to
    # @param [Grit::Actor] actor The actor object from Grit
    def initialize(repo, actor)
      super repo
      @id   = actor.email
      @name = actor.name

      if @id.respond_to? :force_encoding
        @id.force_encoding 'utf-8'
        @name.force_encoding 'utf-8'
      end
    end

  end

end
