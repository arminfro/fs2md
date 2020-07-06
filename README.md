# Fs2md

It's a file-collector and -generator for Markdown files.

It parses a directory recursive and collects all Markdown Files to generate a single Markdown file.

If wished it calls pandoc to print several formats, specific ranges, each node and a beamer version, for all at once.

## Features

* Directories and Files can be ordered by a filename prefix
  * 3 numbers and an underscore controls the order
  * filename is heading of the section (with stripped order numbers)
  * Depth and place of section is analog to file structure
  * Underscores in filenames gets substituted with blanks
* Can produce a regular Document and also a beamer version
  * beamer version reduces all headings to h1, with `--print-beamer`
* Can produce each document (and all sub-documents) separately, with `--print-each`
* Can trim the directory tree to a specific range, with `--from-index` and  `--until-index`
  * finds common parent to prevent structure of TOC
  * To see the indeces exe `fs2md show DIR` command
* Has a `pandoc` option to compile markdown with `pandoc`
  * It takes a Hash, valid keys are `format` and `options`
  * `format`, accepts multiple values, e.g. `--pandoc=format:"pdf, html"`
    * this sets the fileformat value for the outputfile, pandoc implies the `--to` option
  * `options`, get passed to pandoc
    * e.g. `--pandoc=options:"--toc --toc-depth 5 -V linkcolor:blue --highlight-style tango --metadata title='MyTitle' --lua-filter=diagram-generator/diagram-generator.lua"`
* Mutated vowel transformation
  * a feature very few will need. It's useful to me cause I need to write German language, while typing it on US keyboard layout (which is just my prefered layout)
  * to substitute letters like `ae` to `ä`, or `ss` to `ß` set `--mutated-vowel-transformation` flag
    * to exclude words pass an array with lowercase excludes, e.g. `--mutated-vowel-excludes=vue heroes elternklasse`
    * the algorithm checks if the word with e.g. `ae` isn't a valid German word (according to `aspell`)
      * excludes word which are a link, in a code block or in inline code
      * [todo] Works currently only if a word has only one candidate to substitute

## Installation

```shell
git clone https://github.com/arminfro/fs2md.git && cd fs2md && gem build fs2md.gemspec && gem install ./fs2md-0.1.0.gem
```

### Requirements

* `pandoc`
* `aspell`

## Usage

Show command is useful to see how your md files are read in.
Values at the beginning of `show` output, `[T], [F], [D]` indicates text-, file- or dirnode.

Print command takes several options, they all can be combined.

```shell
$ fs2md --help
Commands:
  fs2md help [COMMAND]  # Describe available commands or one specific command
  fs2md print           # converts document tree to md
  fs2md show            # show file tree with indices
```

```shell
$ fs2md help show
Usage:
  fs2md show

Options:
  [--type=TYPE]  # pass 'dir', 'file' or 'text'
                 # Default: text

show file tree with indices
```

```shell
$ fs2md help print
Usage:
  fs2md print PATH [options]

Options:
  [--until-index=N]                                                      # pass number value to print until
  [--from-index=N]                                                       # pass number value to print from
  [--print-beamer], [--no-print-beamer]                                  # determines if a beamer version shall be printed as well
  [--print-each], [--no-print-each]                                      # if true, every dir- and filenode gets printed to pdf
  [--pandoc=key:value]                                                   # If you wish to use pandoc to compile your markdown files as well.

Pass at least a value for format, like `--pandoc=format:"pdf"`
Note: Format is used to specify output filename, pandoc implies the --to option.
      Could be also comma-seperated list of formats, like `--pandoc=format:"pdf,html"`

You can also pass other pandoc arguments, in options key, like:
`fs2md print MyFolder --pandoc=options:"--toc -V linkcolor:blue --highlight-style tango" format:"pdf"`

  [--mutated-vowel-transformation], [--no-mutated-vowel-transformation]  # determine if spell correction gets applied (with aspell). It's used to transform mutated vowels in German language. Pass a mutated vowel expception list to exclude specific words from transforming
  [--mutated-vowel-excludes=one two three]                               # Pass a list of words which gets excluded by mutated vowel transformation

converts document tree to md
```

### Caveats, Todos

* Alpha state
* Requirements could be optional, but they aren't yet
* It's assumed you use two spaces for indentation
* Pictures should be placed in the same directory where they are used in your md file, picture path is relative
  * todo, relativ path
  * means you need to reference your pictures just by filename (no path required)

## Development

The logic consists of four classes and three structs.

Subclasses `DirNode`, `FileNode`, `TextNode` extending `Node`.
`Struct`s: `FileNodeContentParser`, `TextNodeContentParser` and `MutatedVowel`.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://www.github.com/arminfro/fs2md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
