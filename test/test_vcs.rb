# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestVCS < Test::Unit::TestCase

  context 'The VCS module' do

    setup do
      require 'metior/vcs'

      module MockVCS
        NAME = :mock
        include VCS
        not_supported :some_feature
      end

      @vcs = Object.new
      @vcs.extend MockVCS
    end

    should 'allow access to the features of a VCS' do
      assert_not MockVCS.supports? :some_feature
      assert_not @vcs.supports? :some_feature
      assert_raise UnsupportedError do
        @vcs.support! :some_feature
      end
    end

    teardown do
      @vcs = nil
      Metior.module_exec { @@vcs_types.delete :mock }
    end

  end

end
