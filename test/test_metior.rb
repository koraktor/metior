# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestMetior < Test::Unit::TestCase

  context 'Metior' do

    should 'should provide several VCS implementations' do
      assert_equal({ :git => Git, :github => GitHub }, Metior.vcs_types)
      assert_equal Git, Metior.vcs(:git)
    end

    should 'raise an error if an implementation does not exist' do
      begin
        Metior.vcs :unknown
        assert false
      rescue
        assert $!.is_a? RuntimeError
        assert_equal 'No VCS registered for :unknown', $!.message
      end
    end

    should 'allow easy creation of a implementation specific repository' do
      assert_kind_of Git::Repository, Metior.repository(:git, File.dirname(File.dirname(__FILE__)))
      assert_kind_of GitHub::Repository, Metior.repository(:github, 'some', 'user')
    end

  end

end
