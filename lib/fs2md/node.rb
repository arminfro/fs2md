# frozen_string_literal: true

class Node
  attr_reader :parent_node, :name, :path
  def initialize(name, path, parent_node = nil)
    @name        = name
    @path        = path
    @parent_node = parent_node
    # puts("#{self.class} init: #{full_path}")
  end

  def full_path
    File.join(@path, @name)
  end

  def parents
    @parents ||= begin
                 parent  = @parent_node
                 parents = []
                 until parent.nil?
                   parents.push(parent)
                   parent = parent.parent_node
                 end
                 parents
               end
  end

  def reject_childs_by_index(i); end

  def depth
    parents.size
  end

  def to_pdf(output_dir)
    return if content.empty?

    d       = is_a?(DirNode)
    outputf = "#{output_dir}/#{@path.sub("#{Dir.pwd}/", '')}#{d ? '' : '/' + @name}"
    dir     = outputf.split('/')[..-2].join('/')
    FileUtils.mkdir_p(dir) unless File.exist?(dir)

    f      = File.open("#{outputf}#{$beamer ? '_beamer' : ''}.md", 'w') { |f| f.write(content) }
    styles = %w[pygments kate monochrome espresso haddock tango zenburn]
    if ARGV.any?('--all-styles')
      styles.each do |style|
        command = "pandoc #{if $beamer
                              '-t beamer'
                            else
                              '--toc --toc-depth 6 -V toc-title=\'Inhaltsverzeichnis\''
      end} -V linkcolor:blue --highlight-style #{style} -s #{outputf}.md -o #{outputf}#{$beamer ? '_beamer' : ''}_style_#{style}.pdf"
        # puts(command)
        system(command)
      end
    else
      command = "pandoc #{if $beamer
                            '-t beamer'
                          else
                            '--toc --toc-depth 6 -V toc-title=\'Inhaltsverzeichnis\''
      end} -V linkcolor:blue --highlight-style #{styles[5]} -s #{outputf}.md -o #{outputf}#{$beamer ? '_beamer' : ''}.pdf"
      system(command)
    end
  end

  def to_s
    "#{'   ' * depth} - #{@name}\n"
  end

  def beautify_name
    @beautify_name ||= begin
                         @name.sub(/\d{1,3}/, '').gsub('_', ' ').strip # .split(' ').join(' ')
                       end
  end
end
