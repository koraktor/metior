# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestLoading < Test::Unit::TestCase

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

  def run(result)
    r, w = IO.pipe
    yield(STARTED, name)
    @_result = result
    fork do
      r.close
      begin
        fail = nil
        setup
        __send__(@method_name)
      rescue Test::Unit::AssertionFailedError => e
        fail = Test::Unit::Failure.new(name, filter_backtrace(e.backtrace), e.message)
      rescue Exception
        raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
        fail = Test::Unit::Error.new(name, $!)
      ensure
        begin
          teardown
        rescue Test::Unit::AssertionFailedError => e
          fail = Test::Unit::Failure.new(name, filter_backtrace(e.backtrace), e.message)
        rescue Exception
          raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
          fail = Test::Unit::Error.new(name, $!)
        end
      end
      Marshal::dump [@_result.assertion_count, fail], w
      w.close
    end
    w.close
    Process.wait
    results = Marshal::load r.read
    r.close
    result.instance_variable_set :@assertion_count, results.first
    fail = results.last
    unless fail.nil?
      @test_passed = false
      if fail.is_a? Test::Unit::Failure
        add_failure fail
      else
        add_error fail
      end
    end
    result.add_run
    yield(FINISHED, name)
  end

end
