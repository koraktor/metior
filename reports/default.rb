# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report

  # @author Sebastian Staudt
  class Default < self

    @@assets = %w{
      images/favicon.png
      javascripts/d3/d3.min.js
      javascripts/d3/d3.time.min.js
      stylesheets/default.css
    }

    @@name = :default

    @@views = [ :index, :calendar ]

    def init
      @commits.modifications if repository.supports? :line_stats
    end

  end

end
