# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::MostSignificantAuthors < View

    requires :line_stats

    def authors
      repository.authors.most_significant(5).values
    end

    def modification_count
      "#{self[:modifications]} line changes"
    end

  end

end
