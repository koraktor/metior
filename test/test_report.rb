# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestReport < Test::Unit::TestCase

  context 'A report' do

    setup do
      require 'metior/repository'

      r = Metior::Repository.new('dummy')
      @report = Metior::Report.create 'default', r
    end

    should 'have some basic information' do
      assert_instance_of Metior::Report::Default, @report
      assert_equal 'default', @report.class.name
      assert_equal [:index], @report.class.views
      assert_equal File.join(Metior::Report::REPORTS_PATH, 'default'),
        @report.path
    end

    should 'be able to generate a HTML report using Mustache' do
      view = mock
      view.expects(:render).once.returns 'content'
      view_class = mock
      view_class.expects(:new).with(@report).once.returns view
      file = mock
      file.expects(:write).with('content').once
      file.expects(:close).once

      target_dir = File.expand_path './a/target/dir'
      @report.expects(:copy_assets).with(target_dir).once
      Mustache.expects(:view_namespace=).with(Metior::Report::Default).once
      Mustache.expects(:view_class).with(:index).once.returns view_class
      File.expects(:open).with(File.join(target_dir, 'index.html'), 'w').once.
        returns file

      @report.generate './a/target/dir'
    end

  end

end
