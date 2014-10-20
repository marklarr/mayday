Easily add custom warnings and errors to your Xcode project's build process.

## Installation

    $ gem install mayday

## Usage

Create a Maydayfile at the root of your project, defining your warnings and errors using `warning`, `error`, `warning_regex`, and `error_regex`.

```ruby
# Maydayfile

# Required
xcode_proj "CoolApp.xcodeproj"
# Required. This will most likely be the same name as your project.
main_target "CoolApp"

# Use regular expressions to define errors or warnings on a line-by-line basis

error_regex "Please remove Copyright boilerplate", /^\/\/  Copyright \(c\).*$/, :files => "*AppDelegate*", :exclude => "Fixtures/SomeDir/Excluded/*"

warning_regex "TODO", /^\/\/\s+TODO:.*$/

# Do more complicated checks or return dynamic messages via blocks
warning :line do |line|
  line.length > 120 ? "Length of line #{line.length} is longer than 120 characters!" : false
end

# You can get the whole file, too
error :file do |entire_file|
  max_number_of_lines = 500
  
  number_of_code_or_comment_lines = entire_file.split("\n").select { |line| line.strip.length > 0 }.count
  if number_of_code_or_comment_lines > max_number_of_lines
    # Map line numbers to errors
    { "1" => "File is #{number_of_code_or_comment_lines} lines long" }
  else
    false
  end
end

```

And then,

    $ mayday
    
Next time you build your project, your errors and warnings will be flagged

![Mayday warnings and errors in Xcode](https://raw.githubusercontent.com/marklarr/mayday/master/docs/example.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6bWFya2xhcnIvbWF5ZGF5L21hc3Rlci9kb2NzL2V4YW1wbGUuanBnIiwiZXhwaXJlcyI6MTQxNDM5MDIxNH0%3D--e7969b95aea1bc76749ae9226d2ac5ffef0cf322)

![Mayday warnings and errors in Xcode, inline](https://raw.githubusercontent.com/marklarr/mayday/master/docs/example_inline.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6bWFya2xhcnIvbWF5ZGF5L21hc3Rlci9kb2NzL2V4YW1wbGVfaW5saW5lLmpwZyIsImV4cGlyZXMiOjE0MTQzOTAzMzh9--bc9abbe40843317e7b6a30a9521ebf6ae457ece2)

### Options

`warning`, `error`, `warning_regex`, and `error_regex` all accept an options hash with any of the following options

* `language` limits to files in the provided language. Accepts `"swift"` and `"objective-c"`.
  * `warning :line, :language => "swift" do ...`
* `files` limits to files that have an absolute path that matches the provided [globs](http://en.wikipedia.org/wiki/Glob_(programming)). Accepts an array.
  * `warning_regex "Foo!", /^barbaz$/, :files => ["*.h"] do ...`
* `exclusions` doesn't run on files that have an absolute path that matches the provided [globs](http://en.wikipedia.org/wiki/Glob_(programming)). Accepts an array.
  * `warning :line, :exclude => ["*/Pods/*"] do ...` **Note, Pods are excluded by default by mayday**

## Benchmarking

You may be concerned about how much overhead this will add to your build process. To see how quickly your `mayday` checks execute, use 

     $ mayday benchmark

## Caveats

* Since `mayday` uses [sourcify]() to write your custom `warning` and `errors` blocks to a build phase, all [gotchas in sourcify](https://github.com/ngty/sourcify#gotchas) apply to your blocks.
* Generating efficient code to write into the build phase is difficult. `MayDay::ScriptGenerator#to_ruby` could definitely by optimized.


## Uninstallation

    $ mayday down

## Contributing

We'd love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a [new Github issue](https://github.com/venmo/synx/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!
