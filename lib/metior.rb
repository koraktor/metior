# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'core_ext/object'
require 'metior/git'
require 'metior/github'
require 'metior/report'
require 'metior/version'

# Metior is a source code history analyzer that provides various statistics
# about a source code repository and its change over time.
#
# @author Sebastian Staudt
module Metior

  # Creates a new repository for the given repository type and path
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @return [Repository] A VCS specific `Repository` instance
  def self.repository(type, *options)
    vcs(type)::Repository.new(*options)
  end

  # Generates a report for the given repository
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @param [String] target_dir The target directory to save the report to
  # @param [String] report The name of the report template to use
  def self.generate_report(type, repo_options, target_dir, report = 'default')
    repo = repository type, *repo_options
    Report.create(report, repo).generate target_dir
  end

  # Calculates simplistic stats for the given repository and branch
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Object, Array<Object>] repo_options The options to supply to the
  #        repository
  # @param [String, Range] range The range of commits for which the commits
  #        should be loaded. This may be given as a string
  #        (`'master..development'`), a range (`'master'..'development'`) or as
  #        a single ref (`'master'`). A single ref name means all commits
  #        reachable from that ref.
  # @return [Hash<Symbol, Object>] The calculated stats for the given
  #         repository and branch
  def self.simple_stats(type, repo_options, range = nil)
    range = vcs(type)::DEFAULT_BRANCH if range.nil?
    repo  = repository type, *repo_options

    commits = repo.commits(range)
    {
      :commit_count     => commits.size,
      :top_contributors => repo.top_contributors(range, 5),
    }.merge commits.activity
  end

end
