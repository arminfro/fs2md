# frozen_string_literal: true

require 'fs2md/version'
require 'thor'
require 'pry'
require 'spellchecker'

module Warning
  def warn(msg); end
end

require 'fs2md/node'
require 'fs2md/dir_node'
require 'fs2md/file_node'
require 'fs2md/text_node'

module Fs2md
  class Cli < Thor
    class << self
      def type_scope_method_option
        method_option :type,
                      type: :string,
                      default: Node.config[:type_scope].to_s,
                      desc: "pass 'dir', 'file' or 'text'",
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
                            'It\'s used to transform mutated vowels in German language',
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
    end

    desc 'print', 'converts document tree to pdf'
    until_indice_method_option
    from_indice_method_option
    print_beamer_method_option
    print_each_method_option
    mutated_vowel_transformation_method_option
    def print(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      Node.config[:mutated_vowel_transformation] = options['mutated-vowel-transformation']
      args                                       = [File.basename(file), path]
      node                                       = File.directory?(path) ? DirNode.new(*args) : FileNode.new(*args)

      if options['until-index'] || options[['from-index']]
        all_nodes   = node.childs(:all_with_self)
        index_range = Cli.indice_options_to_index_range(options, all_nodes.size)
        node        = Node.reroot_by_index_range(index_range, all_nodes)
      end

      node.print

      if options['print-beamer']
        Node.config[:print_beamer] = true
        node.print
      end

      return unless options['print-each']

      node.childs(:all).reject { |c| c.is_a?(TextNode) }.each(&:print)
    end

    desc 'show', 'show file tree with indices'
    type_scope_method_option
    def show(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      if options[:type] && %w[dir file text].include?(options[:type])
        Node.config[:type_scope] = options[:type].to_sym
      end

      args = [File.basename(file), path]
      node = File.directory?(path) ? DirNode.new(*args) : FileNode.new(*args)
      puts node
      puts "[#{node.childs(:all_with_self).last.index}] - End"
    end
  end
end
