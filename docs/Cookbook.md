# Cookbook

The mayday cookbook contains common warning/error checks that are ready to use out-of-the-box and can be customized as you please.

* [Reminders](#reminders)
* [Lint](#lint)

## Reminders

```ruby
# Warning for TODO comments
warning_regex 'TODO', /\s*\/\/\s*TODO:/
```

```ruby
# Warning for FIXME comments
warning_regex 'FIXME', /\s*\/\/\s*FIXME:/
```

## Lint

```ruby
# Warning for lines that are more than 120 columns long
warning :line { |line| line.length > 120 ? "Line is #{line.length} columns long" : false }
```

```ruby
# Warning for files that are more than 500 lines long
warning :file do |entire_file|
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

```ruby
# Warning for Copyright placed at the beginning of every file
warning_regex "Please remove Copyright boilerplate", /^\/\/  Copyright \(c\).*$/
```

