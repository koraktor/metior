# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/actor'

module Metior

  module MockVCS

    class Actor < Metior::Actor

      def self.id_for(actor)
        actor.last
      end

      def initialize(repo, actor)
        super repo

        @id   = actor.last
        @name = actor.first
      end
    end

  end

end
