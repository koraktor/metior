# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'

class TestMetior < Test::Unit::TestCase

  context 'Metior' do

    should 'should provide a VCS implementation for Git' do
      assert_equal VCS::Git, Metior.find_vcs(:git)
    end

    should 'raise an error if an implementation does not exist' do
      begin
        Metior.find_vcs :unknown
        assert false
      rescue
        assert_instance_of UnknownVCSError, $!
        assert_equal 'No VCS registered for :unknown', $!.message
      end
    end

    should 'allow easy creation of an adapter specific repository' do
      assert_kind_of Adapter::Grit::Repository, Metior.repository(:grit, File.dirname(File.dirname(__FILE__)))
      assert_kind_of Adapter::Octokit::Repository, Metior.repository(:octokit, 'some', 'user')
    end

    should 'allow easy creation of a VCS specific repository with the default adapter' do
      assert_kind_of Adapter::Grit::Repository, Metior.repository(:git, File.dirname(File.dirname(__FILE__)))
    end

    should 'allow easy generation of a report' do
      require File.join(Report::REPORTS_PATH, 'default')

      repo1   = mock
      repo1.expects(:current_branch).returns 'master'
      report1 = mock
      report1.expects(:generate).once
      repo2   = mock
      report2 = mock
      report2.expects(:generate).once

      Metior.expects(:repository).with(:git, '/some/path').once.returns(repo1)
      Metior.expects(:repository).with(:github, 'some/repo').once.returns(repo2)

      Report::Default.expects(:new).with do |repository, range|
        repository == repo1 && range == 'master'
      end.once.returns(report1)
      Report::Default.expects(:new).with do |repository, range|
        repository == repo2 && range == 'development'
      end.once.returns(report2)

      Metior.report(:git, '/some/path', '/target/dir')
      Metior.report(:github, 'some/repo', '/target/dir', 'development')
    end

  end

end
