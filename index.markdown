---
layout: default
title:  About
---

<em>Metior</em> is a source code history analyzer API that provides various
statistics about a source code repository and its change over time.

Currently, it provides access to Git repositories using either file system
access or directly on [GitHub][1] using GitHub's HTTP API.

## About the name

The latin word <em>“metior”</em> means <em>“I measure”</em>. That's just what
<em>Metior</em> does – measuring source code histories.

## Installation

<em>Metior</em> is available as a Ruby gem and requires Ruby 1.8.7+ (other Ruby
implementations are also supported). It can be easily installed using the
following command:

{% highlight bash %}
$ gem install metior
{% endhighlight %}

If you want to use the development code you should clone the Git repository:

{% highlight bash %}
$ git clone git://github.com/koraktor/metior
$ cd rubikon
$ rake install
{% endhighlight %}

## Documentation

Get started having a look at some code snippets on the [examples][2] pages.

The complete documentation of <em>Metior</em>'s Ruby API can be seen at
[RubyDoc.info][3]. The API documentation of the current development version
is also available [there][4].

## Contact

If you have questions, problems, or suggestions feel free to get in touch:

* Twitter: [@metiorstats][5]
* Convore: [Metior's group][6]
* GitHub:  [Issue Tracker][7] or directly to [koraktor][8]

## Further information

* Source code repository at [GitHub][8]
* Project statistic at [Ohloh][9]
* Continuous integration at [Travis CI][10]

Thanks for these great services.

 [1]:  https://github.com
 [2]:  usage.html
 [3]:  http://rubydoc.info/gems/metior/frames
 [4]:  http://rubydoc.info/github/koraktor/metior/master/frames
 [5]:  http://twitter.com/metiorstats
 [6]:  http://convore.com/metior
 [7]:  https://github.com/koraktor/metior/issues
 [8]:  https://github.com/koraktor
 [9]:  https://github.com/koraktor/metior
 [10]:  https://ohloh.com/p/metior
 [11]: http://travis-ci.org/koraktor/metior
