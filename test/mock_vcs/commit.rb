# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'mock_vcs/actor'
require 'metior/commit'

module Metior

  module MockVCS

    class Commit < Metior::Commit

      def initialize(repo, range, commit)
        super repo, range

        @additions      = commit[:impact].first.to_i
        @authored_date  = Time.at commit[:info][6].to_i
        @committed_date = Time.at commit[:info][3].to_i
        @deletions      = commit[:impact].last.to_i
        @id             = commit[:ids].first
        @message        = commit[:info].first

        authors = repo.authors range
        @author = authors[Actor.id_for commit[:info][4..5]]
        @author = Actor.new repo, commit[:info][4..5] if author.nil?
        @author.add_commit self

        committers = repo.committers range
        @committer = committers[Actor.id_for commit[:info][1..2]]
        @committer = Actor.new repo, commit[:info][1..2] if @committer.nil?
        @committer.add_commit self

        @added_files    = []
        @modified_files = []
        @deleted_files  = []
        commit[:files].each do |file|
          if file.first == 'A'
            @added_files    << file.last
          elsif file.first == 'A'
            @deleted_files  << file.last
          else
            @modified_files << file.last
          end
        end
      end

    end

  end

end
