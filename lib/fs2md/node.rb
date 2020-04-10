# frozen_string_literal: true

class Node
  attr_reader :parent, :name, :path, :childs
  def initialize(path, parent = nil)
    @path   = path
    @parent = parent
    @childs = read
  end

  def depth
    parents.size
  end

  def to_s
    "[#{index}]#{'   ' * depth} - #{@name} \n"
  end

  def parents
    @parents ||= begin
                 p       = @parent
                 parents = []
                 until p.nil?
                   parents.push(p)
                   p = p.parent
                 end
                 parents
               end
  end

  def siblings(mode = :all)
    @siblings ||= begin
                    return [] unless @parent

                    parent_childs = @parent.childs
                    case mode
                    when :all
                      parent_childs
                    when :before_self
                      index_self = parent_childs.index(self)
                      return [] if index_self < 1

                      parent_childs[0..(index_self - 1)]
                    end
                  end
  end

  def index
    @index ||= begin
               return 0 unless @parent

               (preceding_node&.index || 0) + 1
             end
  end

  def preceding_node
    @preceding_node ||= begin
                        return nil unless @parent

                        last_sibling = siblings(:before_self).last

                        return @parent if last_sibling.nil?

                        until last_sibling.is_a?(FileNode)
                          last_sibling = last_sibling.childs.last
                        end
                        last_sibling || @parent
                      end
  end

  def to_pdf(output_dir)
    return if content.empty?

    d        = is_a?(DirNode)
    outputf  = "#{output_dir}/#{@path.sub("#{Dir.pwd}/", '')}#{d ? '' : '/' + @name}"
    dir      = outputf.split('/')[..-2].join('/')
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    filename = "#{outputf}#{$beamer ? '_beamer' : ''}"

    File.open("#{filename}.md", 'w') { |f| f.write(content) }
    styles  = %w[pygments kate monochrome espresso haddock tango zenburn]
    command = "pandoc #{if $beamer
                          '-t beamer'
                        else
                          '--toc --toc-depth 6 -V toc-title=\'Inhaltsverzeichnis\''
    end} -V linkcolor:blue --highlight-style #{styles[5]} -s #{filename}.md -o #{filename}.pdf"
    system(command)
  end

  def beautify_name
    @name.sub(/\d{1,3}/, '').gsub('_', ' ').strip
  end
end
