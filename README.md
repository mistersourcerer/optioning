# Optioning

An easy way to retrieve, store, filter, transform and deprecate `options` passed
to a method. Where `options` are the keys in our beloved `Hash` as last parameter
in a method call.

## Status
[![Gem Version](https://badge.fury.io/rb/optioning.svg)](http://badge.fury.io/rb/hashing)
[![Build Status](https://travis-ci.org/ricardovaleriano/optioning.svg?branch=master)](http://travis-ci.org/ricardovaleriano/hashing?branch=master)
[![Code Climate](https://codeclimate.com/github/ricardovaleriano/optioning.png)](https://codeclimate.com/github/ricardovaleriano/hashing)
[![Inline docs](http://inch-pages.github.io/github/ricardovaleriano/optioning.png)](http://inch-pages.github.io/github/ricardovaleriano/optioning)

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

### An "end to end" example

Given the following class:

```ruby
require 'optioning'

class FileExample
  def initialize(path, commit, content)
    @content = content
    @path, @commit = path, commit
  end

  def export
    hasherize :path, :commit,
      to_hash: ->(){},
      store: "NO!",
      persist: "I will persist!"
  end

  private

  def hasherize(*values_and_options)
    # ...
  end
end
```

And the following implementation of the private method `#hasherize`, which uses
`Optioning` to retrieve the arguments and options passed to it:

```ruby
optioning = Optioning.new values_and_options
optioning.deprecate :to_hash, :to, "v2.0.0"
optioning.recognize :persist
optioning.process caller

puts "\n#{'*'* 80}"
puts "I should export the follow ivars: #{optioning.values}"
puts optioning.on :to
puts optioning.on :persist
puts optioning.on :store
```

If you call the `#export` method in an instance of `FileExample` like this:

```ruby
file = FileExample.new('/some/file.rb', 'cfe9aacbc02528b', '#omg! such file!')
file.export
```

The result will be:

```
NOTE: option `:to_hash` is deprecated; use `:to` instead. It will be removed on or after version v2.0.0.
Called from examples/file.rb:15:in `export'.
NOTE: unrecognized option `:store` used.
You should use only the following: `:to`, `:persist`
Called from examples/file.rb:15:in `export'.
********************************************************************************
I should export the follow ivars: [:path, :commit]
#<Proc:0x007fa9658631a0@examples/file.rb:16 (lambda)>
I will persist!
NO!
```

To play with this example go to the file `examples\file.rb` in this project.

### A more step by step example

Given the following `File` class:

```ruby
class File
  def initialize(path, commit = nil, content = nil)
    @path, @commit, @content = path, commit, content
  end
end
```

And a module called `Hashing`, which defines a method `.serialize` that allow
you configure which `ivars` should be used to convert instances of `File` into a
`Hash` like this:

```ruby
{
  path: @path,
  commit: @commit,
  content: @content
}
```

And I can configure a transformation in the values of `path`, `commit` and
`content` when transforming it into a `Hash` like so:

```ruby
require 'hashing'

class File
  extend Hashing

  hasherize :path, :commit, to_hash: ->(value) { value.downcase }
end
```

As the implementor of this module and the `.hasherize` method, I want to be able
to use an instance of `Optioning`, so I can store and retrieve the `ivars` and
the `options` passed to be used along those `ivars`:

```ruby
module Hashing
  def hasherize(*ivars_and_options)
    @options = Optioning.new ivars_and_options

    # ...
  end
end
```

Now in the `Optioning` instance, I can call the following (among others)
methods:

```ruby
@options.raw
# => [:path, :commit, {to_hash: #<Proc:0x007fa4120bd318@(irb):42 (lambda)>}]

@options.values
# => [:path, :commit]

@options.on :to_hash
# => #<Proc:0x007fa4120bd318@(irb):42 (lambda)>
```

### Deprecating options

Now, following our example, if you need to deprecat the `:to_hash` option in
favor of the new `:to` option, you could do:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.deprecate :to_hash, :to

  # ...
end
```

This will replace the deprecated option `:to_hash` for the new one named `:to`
so you can do the following invocation to recover the value passed to the
deprecated `option`:

```ruby
@options.on :to

# => #<Proc:0x007fa4120bd318@(irb):42 (lambda)>
```

#### Deprecation warnings

You can alert your user about those deprecations using the `#deprecated_warn`
method:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.deprecate :to_hash, :to
  @options.deprecation_warn

  # ...
end
```

You can inform the date when the deprecation will not be available anymore.
These date will be part of the deprecation message:

```ruby
@options.deprecate :to_hash, :to, 2015, 05
@options.deprecation_warn

# => NOTE: option `:to_hash` is deprecated use `:to` instead. It will be
#    removed on or after 2015-05-01."
```

Or if you prefer, you can specify a version of your software that pretend to
remove the deprecated thing:

```ruby
@options.deprecate :to_hash, :to, "v2.0.0"
@options.deprecation_warn

# => NOTE: option `:to_hash` is deprecated use `:to` instead. It will be
#    removed on or after version v2.0.0"
```

And finally, you can add information about where te deprecated option was used
by passing the `caller` to the `deprecation_warn` method.

##### Caller info

Sometimes you will want to show information about where the call with the
deprecated option took place. If this is the case, you can pass the caller info
when instantiating the `Optioning`:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.deprecate :to_hash, :to
  @options.deprecated_warn caller

  # ...
end
```

##### Calling a deprecated option

If you call a deprecated option, the return will be `nil`, and the deprecation
warning will be exhibited.

 * [ ] maybe we should allow a deprecation strategy? To choose between warning
   or exception when a deprecated options is called?

### Unrecongnized options

To configure the options that matters to your program, use the method
`#recognize`. And to warn the user in case an unrecognized option is used, call
the `#unrecognized_warn` method:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.recognize :from
  @options.unrecognized_warn

  # ...
end
```

Now, if a user pass an option different than the `:from` one, a warning will
inform that the option is not recognized.

#### Do I Need to register deprecated options as recognized?

Fortunately no. You just need to register your deprecations as usual:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.recognize :from
  @options.deprecate :to_hash, :to
  @options.deprecated_warn
  @options.unrecognized_warn

  # ...
end
```

The `#deprecate` method already knows what to do (that is register the `option`
`:to_hash` as recognized. To sum up, in this last example, the options `:from`
and `:to` are already recongnized by the `Optioning` instance.

### `#process`

The `#process` method will replace all deprecations, warn about them and warn
about unrecognized options all at once, so you can use it like this:

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new ivars_and_options
  @options.recognize :from
  @options.deprecate :to_hash, :to
  @options.process

  # ...
end
```

If you want the deprecation warning messages with the information about where
the deprecated options were passed, you can pass the `caller` info to the
`process` method:

```ruby
@options.process caller
```

### Fluent interface

And finally, just for a matter of taste, `#deprecate`, `#recognize` and
`#process` returns the `Optioning` instance itself, so you can write the last
example like this (if you want)

```ruby
def hasherize(*ivars_and_options)
  @options = Optioning.new(ivars_and_options).recognize(:from)
  @options.deprecate(:to_hash, :to).process

  # ...
end
```

## Contributing

This is a rapid "scratch your own itch" kind of project. It will make me really happy if it can be used used in your software anyhow. If you need something different than what is in it, or can solve us some bugs or add documentation, it will be very well received!

Here is how you can help this gem:

1. Fork it ( http://github.com/ricardovaleriano/optioning/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
