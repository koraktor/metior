# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class Metior::Report

  class Dummy < self
    assets %w{images javascripts stylesheets}
    views [ :index ]
  end

end

class TestReport < Test::Unit::TestCase

  context 'A report' do

    setup do
      require 'metior/repository'

      r = Metior::Repository.new('dummy')
      r.stubs(:commits).returns CommitCollection.new
      r.stubs(:current_branch).returns 'master'
      r.stubs(:vcs).returns Metior::Git
      @report = Metior::Report::Dummy.new r
    end

    should 'have some basic information' do
      report = Metior::Report::Dummy
      assert_equal %w{images javascripts stylesheets}, report.assets
      assert_equal 'dummy', Metior::Report::Dummy.name
      assert_equal [:index], report.views
      assert_equal File.join(Metior::Report::REPORTS_PATH, 'dummy'),
        report.path
    end

    should 'be able to generate a HTML report using Mustache' do
      view = mock
      view.expects(:render).once.returns 'content'
      view.expects(:template_name=).with :index
      view_class = mock
      view_class.expects(:new).with(@report).once.returns view
      file = mock
      file.expects(:write).with('content').once
      file.expects(:close).once

      Metior::Report::Dummy.expects(:find).with('templates/index.mustache').
        returns ''
      Metior::Report::Dummy.expects(:find).with('views/index.rb').
        returns ''

      target_dir = File.expand_path './a/target/dir'
      @report.expects(:copy_assets).with(target_dir).once
      Mustache.expects(:view_namespace=).with(Metior::Report::Dummy).once
      Mustache.expects(:view_class).with(:index).once.returns view_class
      File.expects(:open).with(File.join(target_dir, 'index.html'), 'wb').once.
        returns file

      @report.generate './a/target/dir'
    end

  end

end
