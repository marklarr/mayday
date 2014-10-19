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

### Options

`warning`, `error`, `warning_regex`, and `error_regex` all accept an options hash with any of the following options

* `language` limits to files in the provided language. Accepts `"swift"` and `"objective-c"`.
  * `warning :line, :language => "swift" do ...`
* `files` limits to files that match the provided [globs](http://en.wikipedia.org/wiki/Glob_(programming)). Accepts an array.
  * `warning_regex "Foo!", /^barbaz$/, :files => ["*.h"] do ...`
* `exclusions` doesn't run on files that match the provided [globs](http://en.wikipedia.org/wiki/Glob_(programming)). Accepts an array.
  * `warning :line, :exclude => ["*/Pods/*"] do ...` **Note, Pods are excluded by default by mayday**

**For file globs, put a `*` at the beginning to match the full system path.**

## Caveats

## Contributing

We'd love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a [new Github issue](https://github.com/venmo/synx/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!