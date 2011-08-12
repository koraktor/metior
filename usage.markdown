---
layout: default
title:  Usage
---

This page shows some examples of how to use <em>Metior</em>. The API aims to be
clean and straightforward, allowing to issue simple commands as well as more
complex queries.

## Reports

The most straightforward use of Metior is probably generating an out-of-the-box
report that analyzes a repository and gives a user-friendly output of the
gathered data.

{% highlight ruby %}
Metior.report :git, '~/open-source/metior', './reports/metior'
Metior.report :github, 'koraktor/metior', './reports/metior'
{% endhighlight %}

## API examples

If you want more sophisticated access to the available data, you can use the
low-level API that provides stats for repositories and their individual commits
and actors.

### One-liner for some basic statistics

{% highlight ruby %}
Metior.simple_stats :git, '~/open-source/metior'
Metior.simple_stats :github, 'koraktor/metior'
{% endhighlight %}

### More fine-grained access to repository statistics

{% highlight ruby %}
repo.commits 'development'         # Get all commits in branch development
repo.file_stats                    # Basic statistics about the files
                                   # contained in a repository
repo.line_history                  # Quick access to lines added and
                                   # removed in each commit
repo.significant_authors           # Get up to 3 of the most important
                                   # authors
repo.significant_commits           # Get up to 3 of the commits changing
                                   # the most lines
repo.authors('master').top 5       # Get the top 5 authors in master
{% endhighlight %}

### Query a collection of commits

{% highlight ruby %}
repo.commits.activity
repo.commits.after '05/29/2010'
repo.commits.additions
repo.commits.authors
repo.commits.before '05/29/2010'
repo.commits.by 'koraktor'
repo.commits.changing 'lib/metior.rb'
repo.commits.deletions
repo.commits.modifications
repo.commits.most_significant 10
repo.commits.with_impact 100
{% endhighlight %}

See documentation of [`Metior::CommitCollection`][2]

### Query a collection of actors

{% highlight ruby %}
repo.authors.authored_commits
repo.authors.comitted_commits
repo.authors.most_significant 10
repo.authors.top 10
{% endhighlight %}

See documentation of [`Metior::ActorCollection`][4]

## Advanced usage

### Chain collection querys

Querys on a collection of commits or actors can be easily chained to achieve
complex filters on the available data.

{% highlight ruby %}
repo.commits.by('koraktor').after('05/29/2010').with_impact 100
repo.authors.top(10).commits.changing 'lib/metior.rb'
{% endhighlight %}

### Specifying commit ranges

Usually, when Metior queries a repository for its commits and authors it will
use the default branch of the VCS, e.g. `master` for Git.

Sometimes it's more useful to not analyze the whole history of a repository's
branch. For example when analyzing the changes from one branch to another, or
from the last released version to the latest code. In that case you will have
to specify a commit range. Specifying a commit range works just like in Git:

{% highlight ruby %}
'master..development'
'deadbeef..HEAD'
'master'..'development'
{% endhighlight %}

Given that your currently checked out branch is `development` and `master`
points to commit `deadbeef`, the above statements are equal. Please also note
the different syntaxes: The first two example are standard strings which
will be parsed by Metior. The other one is a Ruby `Range` object which can be
used by Metior right away.

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
 [3]: http://rubydoc.info/gems/metior/Metior/CommitCollection
 [4]: http://rubydoc.info/gems/metior/Metior/ActorCollection
