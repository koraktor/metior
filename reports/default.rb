# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

# @author Sebastian Staudt
class Metior::Report::Default

  include Metior::Report

  as :default

  assets %w{
    images/favicon.png
    javascripts/d3/d3.v2.min.js
    stylesheets/default.css
  }

  views [ :index, :calendar, :impact ]

  def init
    @commits.modifications if repository.supports? :line_stats
  end

end
