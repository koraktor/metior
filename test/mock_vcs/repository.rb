# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/repository'
require 'mock_vcs/commit'

module Metior

  module MockVCS

    NAME = :mock

    include VCS

    class Repository < Metior::Repository

      DEFAULT_BRANCH = 'master'

      include Metior::MockVCS

      def initialize(path)
        super path

        @file = File.open(File.expand_path(path), 'r')
        @file.set_encoding 'utf-8' if @file.respond_to? :set_encoding
      end

      def load_commits(range)
        commits = []

        commit = {}
        @file.lines.each do |line|
          line.strip!

          next if line.empty?

          if line.match /^[AMD]\0/
            commit[:files] = [] unless commit.key? :files
            commit[:files] << line.split("\0")
          elsif line.match /\d+\0\d+$/
            commit[:impact] = line.split("\0")

            if commits.empty?
              if range.first != '' && !commit[:ids].include?(range.first)
                commit = {}
                next
              end
            elsif commit[:ids].include? range.last
              break
            end

            commits << commit
            commit = {}
          else
            line = line.split("\0")
            ids = [line[0]]
            ids += line[1][2..-2].split(', ') unless line[1].empty?
            commit[:ids]  = ids
            commit[:info] = line[2..-1]
          end
        end

        commits
      end

    end

  end

end
