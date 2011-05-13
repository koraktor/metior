# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestClassLoading < Test::Unit::TestCase

  context 'Metior' do

    should 'load basic modules and dependencies first' do
      assert Object.const_defined? :Metior
      assert Metior.const_defined? :Git
      assert Metior.const_defined? :GitHub
      assert Metior.const_defined? :VCS
      assert Metior.const_defined? :VERSION

      assert !Metior.const_defined?(:Actor)
      assert !Metior.const_defined?(:Commit)
      assert !Metior.const_defined?(:Repository)
      assert !Metior::Git.const_defined?(:Actor)
      assert !Metior::Git.const_defined?(:Commit)
      assert !Metior::Git.const_defined?(:Repository)
      assert !Metior::GitHub.const_defined?(:Actor)
      assert !Metior::GitHub.const_defined?(:Commit)
      assert !Metior::GitHub.const_defined?(:Repository)

      assert !Object.const_defined?(:Grit)
      assert !Object.const_defined?(:Octokit)
    end

    should 'load requirements when using Git' do
      Metior::Git::Repository

      assert Metior.const_defined? :Actor
      assert Metior.const_defined? :Commit
      assert Metior.const_defined? :Repository
      assert Metior::Git.const_defined? :Actor
      assert Metior::Git.const_defined? :Commit
      assert Metior::Git.const_defined? :Repository

      assert Object.const_defined? :Grit
    end

    should 'load requirements when using GitHub' do
      Metior::GitHub::Repository

      assert Metior.const_defined? :Actor
      assert Metior.const_defined? :Commit
      assert Metior.const_defined? :Repository
      assert Metior::GitHub.const_defined? :Actor
      assert Metior::GitHub.const_defined? :Commit
      assert Metior::GitHub.const_defined? :Repository

      assert Object.const_defined? :Octokit
    end

  end

end
