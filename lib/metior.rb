# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
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

  # Creates a new repository for the given repository type and path
  #
  # @param [Symbol] type The type of the repository, e.g. +:git+
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @return [Repository] A VCS specific +Repository+ instance
  def self.repository(type, *options)
    vcs(type)::Repository.new *options
  end

  # Calculates simplistic stats for the given repository and branch
  #
  # @param [Symbol] type The type of the repository, e.g. +:git+
  # @param [String] path The file system path of the repository
  # @param [String] branch The repository's 'branch to analyze. +nil+ will use
  #        the VCS's default branch
  # @return [Hash] The calculated stats for the given repository and branch
  def self.simple_stats(type, path, branch = nil)
    repo = repository type, path
    branch ||= vcs::DEFAULT_BRANCH

    {
      :authors        => repo.authors(branch).values,
      :commit_count   => repo.commits(branch).size,
      :top_committers => repo.top_contributors(branch, 3)
    }
  end

end
