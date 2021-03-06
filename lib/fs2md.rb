# frozen_string_literal: true

require 'fs2md/version'
require 'thor'
require 'spellchecker'

begin
  require 'pry'
rescue LoadError; end
require 'fs2md/node'
require 'fs2md/dir_node'
require 'fs2md/file_node'
require 'fs2md/text_node'
require 'fs2md/mutated_vowel'
require 'fs2md/file_node_content_parser'
require 'fs2md/text_node_content_parser'

module Fs2md
  class Cli < Thor
    class << self
      def type_scope_method_option
        method_option :type,
                      type: :string,
                      default: Node.config[:type_scope].to_s,
                      desc: "pass 'dir', 'file' or 'text'. lower node type includes higher node types",
                      required: false
      end

      def from_indice_method_option
        method_option 'from-index',
                      type: :numeric,
                      desc: 'pass number value to print from',
                      required: false
      end

      def until_indice_method_option
        method_option 'until-index',
                      type: :numeric,
                      desc: 'pass number value to print until',
                      required: false
      end

      def mutated_vowel_transformation_method_option
        method_option 'mutated-vowel-transformation',
                      type: :boolean,
                      default: Node.config[:mutated_vowel_transformation],
                      desc: 'determine if spell correction gets applied (with aspell). ' \
                            'It\'s used to transform mutated vowels in German language' \
                            'Pass a mutated vowel expception list to exclude specific words from mutation',
                      required: false
      end

      def mutated_vowel_excludes_option
        method_option 'mutated-vowel-excludes',
                      type: :array,
                      default: Node.config[:mutated_vowel_excludes],
                      desc: 'Pass a list of words which gets excluded by mutated vowel transformation',
                      required: false
      end

      def print_each_method_option
        method_option 'print-each',
                      type: :boolean,
                      default: false,
                      desc: 'if true, every dir- and filenode gets printed to pdf',
                      required: false
      end

      def print_beamer_method_option
        method_option 'print-beamer',
                      type: :boolean,
                      default: Node.config[:print_beamer],
                      desc: 'determines if a beamer version shall be printed as well',
                      required: false
      end

      def pandoc_method_option
        method_option 'pandoc',
                      type: :hash,
                      default: Node.config[:pandoc],
                      required: false,
                      desc: <<~DESC
                        If you wish to use pandoc to compile your markdown files as well.

                        Pass at least a value for format, like `--pandoc=format:"pdf"`
                        Note: Format is used to specify output filename, pandoc implies the --to option.
                              Could be also comma-seperated list of formats, like `--pandoc=format:"pdf,html"`

                        You can also pass other pandoc arguments, in options key, like:
                        `fs2md print MyFolder --pandoc=options:"--toc -V linkcolor:blue --highlight-style tango" format:"pdf"`
                      DESC
      end

      def indice_options_to_index_range(options, node_size)
        index_range = 0..(node_size - 1)
        if options['until-index'] && options['until-index'] <= index_range.last
          index_range = 0..(options['until-index'])
        end
        if options['from-index'] && options['from-index'] >= 0
          index_range = (options['from-index'])..index_range.last
        end
        index_range
      end

      def parse_path(path)
        File.expand_path(path)
      end

      def print(node)
        if options['print-each']
          node.childs(:all).reject { |c| c.is_a?(TextNode) }.each(&:generate_md)
        else
          node.generate_md
        end
      end
    end

    desc 'print PATH [options]', 'converts document tree to md'
    until_indice_method_option
    from_indice_method_option
    print_beamer_method_option
    print_each_method_option
    pandoc_method_option
    mutated_vowel_transformation_method_option
    mutated_vowel_excludes_option
    def print(path_arg)
      path = Cli.parse_path(path_arg)
      file = File.expand_path(path)
      return puts('not valid path') unless File.exist?(file)

      if options['mutated-vowel-transformation']
        Node.config[:mutated_vowel_transformation] = options['mutated-vowel-transformation']
      end
      if options['mutated-vowel-excludes']
        Node.config[:mutated_vowel_excludes]       = options['mutated-vowel-excludes']
      end

      node = File.directory?(path) ? DirNode.new(path) : FileNode.new(path)

      if options['until-index'] || options[['from-index']]
        all_nodes   = node.childs(:all_with_self)
        index_range = Cli.indice_options_to_index_range(options, all_nodes.size)
        node        = Node.reroot_by_index_range(index_range, all_nodes)
      end

      Node.config[:pandoc] = options[:pandoc] if options[:pandoc].keys.size.positive?

      Cli.print(node)

      return unless options['print-beamer']
      Node.config[:print_beamer] = true
      Cli.print(node)
    end

    desc 'show', 'show file tree with indices'
    type_scope_method_option
    def show(path_arg)
      path = Cli.parse_path(path_arg)
      file = File.expand_path(path)
      return puts('not valid path') unless File.exist?(file)

      if options[:type] && %w[dir file text].include?(options[:type])
        Node.config[:type_scope] = options[:type].to_sym
      end

      node = File.directory?(path) ? DirNode.new(path) : FileNode.new(path)
      puts node
    end
  end
end
