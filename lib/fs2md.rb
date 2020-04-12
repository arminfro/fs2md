# frozen_string_literal: true

require 'fs2md/version'
require 'thor'
require 'pry'

module Warning
  def warn(msg); end
end

require 'fs2md/node'
require 'fs2md/dir_node'
require 'fs2md/file_node'
require 'fs2md/text_node'

module Fs2md
  ORDER = [DirNode, FileNode, TextNode].freeze
  class Cli < Thor
    class << self
      def type_scope_method_option
        method_option :type,
                      type: :string,
                      default: 'file',
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
    def print(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      args      = [File.basename(file), path]
      node      = File.directory?(path) ? DirNode.new(*args) : FileNode.new(*args)
      if options['until-index'] || options[['from-index']]
        all_nodes   = node.childs(:all)
        index_range = Cli.indice_options_to_index_range(options, all_nodes.size)
        node        = Node.reroot_by_index_range(index_range, all_nodes)
      end
      node.print
      puts 'Successfully printed'
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
      puts "[#{node.childs(:all).last.index}] - End"
    end
  end
end
