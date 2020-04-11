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
    def self.config_method_option
      method_option :type,
                    type: :string,
                    default: :dir,
                    desc: "pass 'dir', 'file' or 'text'",
                    required: false
    end

    desc 'show', 'show file tree with indeces'
    config_method_option
    def show(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      if options[:type] && %w[dir file text].include?(options[:type])
        Node.config = { type_scope: options[:type].to_sym }
      end

      args        = [File.basename(file), path]
      root_node   = File.directory?(path) ? DirNode.new(*args) : FileNode.new(*args)
      puts root_node
    end

    desc 'original_sequence', 'pass path of documents'
    def original_sequence(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      args        = [File.basename(file), path]
      Node.config = { type_scope: :file }
      root_node   = File.directory?(path) ? DirNode.new(*args) : FileNode.new(*args)
      # puts root_node.dirs(:all)
      puts root_node.to_s
      # root_node.childs.each_with_index { |c, i| puts "[#{i}]: #{c.name}" }
      # $beamer = false
      # root_node.print
      # $beamer   = false
      # root_node.print
    end
  end
end
