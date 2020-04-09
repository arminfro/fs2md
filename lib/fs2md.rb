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
  class Cli < Thor
    desc 'original_sequence', 'pass path of documents'
    def original_sequence(path)
      file = File.expand_path(path)
      return 'not valid path' unless File.exist?(file)

      $beamer = true
      dd      = DirNode.new(File.basename(file), path)
      dd.read_tree
      puts dd
      # dd.childs.each_with_index { |c, i| puts "[#{i}]: #{c.name}" }
      # dd.print
      # $beamer = false
      # dd.print
      puts ''
    end
  end

  class Error < StandardError; end
  # Your code goes here...
end
