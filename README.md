[![Build Status](https://travis-ci.org/hugopl/textui.svg?branch=master)](https://travis-ci.org/hugopl/textui)

# Archived

Nowadays I use [Crystal GTK4](https://hugopl.github.io/gtk4.cr) to write keyboard friendly GUI applications, so I don't have any plans on work on this anymore.

# TextUI

A simple [Crystal](https://https://crystal-lang.org/) UI framework for terminal interfaces backed by [termbox](https://github.com/nsf/termbox).

**It still in a pre-alpha state**, API is not stable at all and this shard exists mainly because I'm using this lib in more than one project. In fact the repository is a fork from [QueryIt](https://github.com/hugopl/queryit), the original project were it was born.

So if you are brave enough to add this shard as a dependency into your project I suggest to use the `commit: ...` attribute into the textui dependency entry on your shard.yml.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     textui:
       github: hugopl/textui
   ```

2. Run `shards install`

## Usage

Example soon...

## Contributing

1. Fork it (<https://github.com/hugopl/textui/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Feature suggestions are welcome, write them in github issues.

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator and maintainer
