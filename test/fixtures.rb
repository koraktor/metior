# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'rash'
require 'time'

module Fixtures

  @@commits = {}

  def self.commits(range)
    unless @@commits.key? range
      file = File.open(File.expand_path("#{File.dirname(__FILE__)}/fixtures/mojombo-grit-master-1b2fe77.txt"), 'r')
      file.set_encoding 'utf-8' if file.respond_to? :set_encoding

      commits = []

      commit = {}
      last_commit = nil
      file.lines.each do |line|
        line.strip!

        next if line.empty?

        if line.match /^[AMD]\0/
          commit[:files] = [] unless commit.key? :files
          commit[:files] << line.split("\0")
        elsif line.match /\d+\0\d+$/
          commit[:impact] = line.split("\0")
        else
          line = line.split("\0")
          ids = [line[0]]
          ids += line[1][2..-2].split(', ') unless line[1].empty?
          commit[:ids]  = ids
          commit[:info] = line[2..-1]

          if commits.empty?
            if !commit[:ids].include?(range.last)
              commit = {}
              next
            end
          elsif commit[:ids].include? range.first
            break
          end

          if commit != {}
            last_commit[:parent] = commit unless last_commit.nil?
            commits << commit
            last_commit = commit
            commit = {}
          end
        end
      end

      @@commits[range] = commits
    end

    @@commits[range]
  end

  def self.commits_as_grit_commits(range)
    commits = commits(range)

    commits.map do |commit|
      parents = commit[:parent].nil? ? [] : [commit[:parent][:ids].first]

      grit_commit = Grit::Commit.new(
        nil,
        commit[:ids].first,
        parents,
        [nil],
        Grit::Actor.new(commit[:info][4], commit[:info][5]),
        Time.at(commit[:info][6].to_i),
        Grit::Actor.new(commit[:info][1], commit[:info][2]),
        Time.at(commit[:info][3].to_i),
        commit[:info].first.lines.to_a
      )

      grit_commit.stubs(:diffs).returns []

      stats = Hashie::Rash.new
      if commit.key? :impact
        stats.additions = commit[:impact].first.to_i
        stats.deletions = commit[:impact].last.to_i
      else
        stats.additions = 0
        stats.deletions = 0
      end
      grit_commit.stubs(:stats).returns stats

      grit_commit
    end
  end

  def self.commits_as_rashies(range)
    commits = commits(range)

    commits.map do |commit|
      Hashie::Rash.new({
        :author         => {
          :email => commit[:info][4],
          :login => commit[:info][5],
          :name  => commit[:info][5]
        },
        :authored_date  => Time.at(commit[:info][6].to_i).to_s,
        :committed_date => Time.at(commit[:info][3].to_i).to_s,
        :committer      => {
          :email => commit[:info][1],
          :login => commit[:info][2],
          :name  => commit[:info][2]
        },
        :id             => commit[:ids].first,
        :message        => commit[:info].first,
        :parents        => ([{ :id => commit[:parent][:ids].first }] rescue [])
      })
    end
  end

end
