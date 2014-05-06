# Optioning

An easy way to retrieve, store, filter, transform and deprecate `options` passed
to a method. Where `options` are the keys our beloved `Hash` as last parameter
for a method call.

## Status
[![Gem Version](https://badge.fury.io/rb/optioning.svg)](http://badge.fury.io/rb/hashing)
[![Build Status](https://travis-ci.org/ricardovaleriano/optioning.svg?branch=master)](http://travis-ci.org/ricardovaleriano/hashing?branch=master)
[![Code Climate](https://codeclimate.com/github/ricardovaleriano/optioning.png)](https://codeclimate.com/github/ricardovaleriano/hashing)

## Installation

Add this line to your application's Gemfile:

    gem 'optioning'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optioning

## Contact

* API Doc: http://rdoc.info/gems/optioning
* Bugs, issues and feature requests: https://github.com/ricardovaleriano/optioning/issues
* Support: http://stackoverflow.com/questions/tagged/optioning-ruby

## Usage

### A general example:

```ruby
# transform.rb
module Trasnform
  def transform(*ivars)
    @options = Optioning.new ivars
    @options.recognize :times
    @options.deprecate :using, :call, "v2.0.0"
    @options.process

    to_call = @options.on :call
    times = @options.on :times

    #... logic to call `to_call` how many times `times` says so.
  end
end

# file.rb
class File
  extend Transform

  transform :path, :content, using: ->(string) { string.upcase }, times: 2,
omg_lol_bbq: "hello world"

  def initialize(path, commit = nil, content = nil)
    @path, @commit, @content = path, commit, content
  end
end

# using_file.rb
require 'file'

 # => Note. ... deprecation warn for using
 # => Note. ... ignoring warn for omg_lol_bbq

```

### A more step by step example

Given the following `File` class:

```ruby
class File
  def initialize(path, commit = nil, content = nil)
    @path, @commit, @content = path, commit, content
  end
end
```

And a class method named `transform` that allows you to indicate some
transformation to be made against specifics `ivars` before returning than (in my
imagination it will be made by creating modified `attr_readers`):

```ruby
class File
  def self.transform(*ivars)
    # logic to create the transformed attr_readers here
  end

  def initialize(path, commit = nil, content = nil)
  #...
end
```

So you can call transform in your class like these:

```ruby
class File
  def self.transform(*ivars)
    # logic to create the transformed attr_readers here
  end

  transform :path, :commit

  def initialize(path, commit = nil, content = nil)
  #...
end
```

But you want to pass the logic of transformation together with the `ivars` that
will be transformed:

```ruby
class File
  def self.transform(*ivars)
    # logic to create the transformed attr_readers here
  end

  transform :path, :commit, using: ->(string_value) { string_value.upcase }

  def initialize(path, commit = nil, content = nil)
  #...
end
```

You can use `Optioning` to capture those parameters and options:

```ruby
class File
  def self.transform(*ivars)
    @options = Optioning.new ivars
    # logic to create the transformed attr_readers here
  end

  transform :path, :commit, using: ->(string_value) { string_value.upcase }

  # ...
end
```

Now you can use the `Optioning` instance to retrieve the values:

```ruby
@options.raw
# => [:path, :commit, {using: #<Proc:0x007fa4120bd318@(irb):1 (lambda)> }]

@options.values
# => [:path, :commit]

@options.on :using
# => #<Proc:0x007fa4120bd318@(irb):1 (lambda)>
```

### Deprecating options

Now, following our example, if you want to deprecat the `:using` option in
favor of the new `:call` option, you could do:

```ruby
def self.transform(*ivars)
  @options = Optioning.new ivars
  @options.deprecate :using, :call, Date.new(2014, 05, 01)
  # logic to create the transformed attr_readers here
end
```

This will replace the deprecated option `:using` for the new one named `:call`
so you can do the following invocation to recover the value passed to the
deprecated `option`:

```ruby
@options.on :call

# => #<Proc:0x007fa4120bd318@(irb):1 (lambda)>
```

#### Deprecation warnings

You can alert your user about those deprecations using the deprecation_warn
method:

```ruby
def self.transform(*ivars)
  @options = Optioning.new ivars
  @options.deprecate :using, :call
  @options.drepaction_warn

  # ...
end
```

You can inform the date when the deprecation will not be available anymore

```ruby
@options.deprecate :using, :call, Date.new(2014, 05, 01)
```

Or if you prefer, you can specify a version of your software that pretend to
remove the deprecated thing:

```ruby
@options.deprecate :using, :call, "v2.0.0"
```

### Ignoring unrecongnized options

If you need, you could fitler the options to mantain just the recognized ones
available:

```ruby
def self.transform(*ivars)
  @options = Optioning.new ivars
  @options.recognized :call
  @options.unrecognized_warn

  # ...
end
```

Now, if a user pass an option different than the `:call` one, a warning will
tell that the option is not recognized and it will be ignored.

#### Need to register deprecated options as recognized?

Fortunatelly no.
You just need to register your deprecation as usual:

```ruby
def self.transform(*ivars)
  @options = Optioning.new ivars
  @options.deprecated :using, :call

  # ...
end
```

The `#deprecated` method already knows what to do (that is register the `option`
using as recognized. To sum up in this last example the options `:using` and
`:call` are already recongnized by the `Optioning` instance.

### `#process`

The `#process` method will replace all deprecations, warn about them and warn
about unrecognized options all at once, so you can use it like this:

```ruby
def self.transform(*ivars)
  @options = Optioning.new ivars
  @options.deprecate :using, :call
  @options.process

  # ...
end
```


## Contributing

1. Fork it ( http://github.com/<my-github-username>/optioning/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
