# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'bundler'

require 'core_ext/object'
require 'metior/git'
require 'metior/github'
require 'metior/version'

# Metior is a source code history analyzer that provides various statistics
# about a source code repository and its change over time.
#
# @author Sebastian Staudt
module Metior

  # Returns the Bundler runtime to access Metior's dependencies
  #
  # @return [Bundler::Runtime] The Bundler runtime instance
  def self.runtime
    @@runtime ||= Bundler::Runtime.new File.dirname(__FILE__),
                                       Bundler.definition
  end

  # Creates a new repository for the given repository type and path
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @return [Repository] A VCS specific `Repository` instance
  def self.repository(type, *options)
    vcs(type)::Repository.new *options
  end

  # Calculates simplistic stats for the given repository and branch
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Array<Object>] options The options for the repository
  # @param [String, Range] range The range of commits for which the commits
  #        should be loaded. This may be given as a string
  #        (`'master..development'`), a range (`'master'..'development'`)
  #        or as a single ref (`'master'`). A single ref name means all
  #        commits reachable from that ref.
  # @return [Hash] The calculated stats for the given repository and branch
  def self.simple_stats(type, *options)
    arity  = vcs(type)::Repository.instance_method(:initialize).arity
    branch = options.delete_at arity
    branch = vcs(type)::DEFAULT_BRANCH if branch.nil?
    repo   = repository type, *options

    {
      :commit_count     => repo.commits(branch).size,
      :top_contributors => repo.top_contributors(branch, 5),
    }.merge Commit.activity(repo.commits(branch))
  end

end
