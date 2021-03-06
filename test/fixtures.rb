# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'hashie/mash'
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

        if line.match /^[A]\0/
          commit[:added_files] = [] unless commit.key? :added_files
          commit[:added_files] << line.split("\0").last.strip
        elsif line.match /^[D]\0/
          commit[:modified_files] = [] unless commit.key? :modified_files
          commit[:modified_files] << line.split("\0").last.strip
        elsif line.match /^[M]\0/
          commit[:deleted_files] = [] unless commit.key? :deleted_files
          commit[:deleted_files] << line.split("\0").last.strip
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
    commits = commits(range).map do |commit|
      parents = commit[:parent].nil? ? [] : [commit[:parent]]

      diffs = []
      commit[:added_files].each do |added_file|
        diffs << { :new_file => true, :b_path => added_file }
      end if commit.key? :added_files
      commit[:deleted_files].each do |deleted_file|
        diffs << { :deleted_file => true, :b_path => deleted_file }
      end if commit.key? :deleted_files
      commit[:modified_files].each do |modified_file|
        diffs << { :b_path => modified_file }
      end if commit.key? :modified_files

      Hashie::Mash.new({
        :author         => {
          :email => commit[:info][5],
          :name  => commit[:info][4]
        },
        :authored_data  => Time.at(commit[:info][6].to_i),
        :committer      => {
          :email => commit[:info][2],
          :name  => commit[:info][1]
        },
        :committed_date => Time.at(commit[:info][3].to_i),
        :diffs          => diffs,
        :id             => commit[:ids].first,
        :message        => commit[:info].first,
        :parents        => parents.map { |p| { :id => p[:ids].first } },
        :stats          => {
          :additions => commit.key?(:impact) ? commit[:impact].first.to_i : 0,
          :deletions => commit.key?(:impact) ? commit[:impact].last.to_i : 0
        }
      })
    end

    HASH_CLASS[commits.map { |c| [c.id, c] }]
  end

  def self.commits_as_rashies(range)
    commits = commits(range).map do |commit|
      Hashie::Mash.new({
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

    HASH_CLASS[commits.map { |c| [c.id, c] }]
  end

end
