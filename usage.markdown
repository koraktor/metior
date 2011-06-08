---
layout: default
title:  Usage
---

This page shows some examples of how to use <em>Metior</em>. The API aims to be
clean and straightforward, allowing to issue simple commands as well as more
complex queries.

## Basic examples

### One-liner for some basic statistics

{% highlight ruby %}
Metior.simple_stats :git, '~/open-source/metior'
{% endhighlight %}

### More fine-grained access to repository statistics

{% highlight ruby %}
repo = Metior::Git::Repository.new '~/open-source/metior'
repo.commits 'development'     # Get all commits in development
repo.file_stats                # Basic statistics about the files
                               # contained in a repository
repo.line_history              # Quick access to lines added and removed
                               # in each commit
repo.significant_authors       # Get up to 3 of the most important authors
                               # authors
repo.significant_commits, 20   # Get up to 20 of the commits changing
                               # the most lines
repo.top_authors 'master', 5   # Get the top 5 authors in master
{% endhighlight %}

## Advanced usage

### Specifying commit ranges

Sometimes it's more useful to not analyze the whole history of a repository's
branch. For example when analyzing the changes from one branch to another, or
from the last released version to the latest code. In that case you will have
to specify a commit range. Specifying a commit range works just like in Git:

{% highlight ruby %}
'master..development'
'master'..'development'
'master..HEAD'
'master'..'HEAD'
'deadbeef..HEAD'
{% endhighlight %}

Given that your currently checked out branch is `development` and `master`
points to commit `deadbeef`, the above statements are equal. Please also note
the different syntaxes: The first, third and fifth example are standards string
which will be parsed by <em>Metior</em>. The second and fourth example are Ruby
`Range` objects which can be used by <em>Metior</em> right away.

### Get statistics about a set of commits

{% highlight ruby %}
Metior::Commit.activity repo.commits
Metior::Commit.activity repo.authors[author_id].commits
{% endhighlight %}

## More …

For a complete overview of <em>Metior</em>'s API including more examples, see the
[gem documentation][1] or the [documentation of the development code][2] at
RubyDoc.info.

 [1]: http://rubydoc.info/gems/metior/frames
 [2]: http://rubydoc.info/github/koraktor/metior/master/frames
