# frozen_string_literal: true

require 'stringio'

def read_stdout(&block)
  tmp = $stdout
  $stdout = tmp = StringIO.new
  block.call
  tmp.string
  ensure
   $stdout = tmp # ensures that always evaluated
end

RSpec.describe Fs2md do
  describe "#test_set" do
    it 'should read fs on show command to specific string' do
      cli         = Fs2md::Cli.new
      show_output = read_stdout { cli.show(File.join(File.expand_path('.'), 'spec', 'test_set'))}
      outputs     = <<~EOF
        [0][D] - test set
        [1][D]    - Documents
        [2][D]       - Beginning
        [3][F]          - Intro
        [4][T]          - Intro
        [5][D]          - Diggin Deeper
        [6][F]             -
        [7][T]             -
        [8][F]             - Intro
        [9][T]             - Intro
        [10][F]             - Outro
        [11][T]             - Outro
        [12][F]       - VowelTransformation
        [13][T]       - VowelTransformation
        [14][F]       - picture path
        [15][T]       - picture path
      EOF
      expect(show_output).to(eql(outputs))
    end

    it 'should print test_set to specific string' do
      cli         = Fs2md::Cli.new
      cli.options = { pandoc: { 'format' => 'pdf'}, 'mutated-vowel-transformation' => true }
      cli.print(File.join(File.expand_path('.'), 'spec', 'test_set'))
      outputs     = <<~EOF
        # Documents

        ## Beginning

        ### Intro

        this file should be included

        ### Diggin Deeper


        Giving a file no name and a low order.
        Content of this file will appear below heading of upper directory name.

        #### Intro

        Et dapibus mi enim sit amet risus. Nulla sollicitudin eros sit amet diam.
        Aliquam ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices
        posüre cubilia Curä; Ut et est. Donec semper nulla in ipsum. Integer elit. In
        pharetra lorem vel ante.

        Pellentesque quis leo eget ante.

        #### Outro

        Claß aptent taciti sociosqu ad litora torqünt per conubia nostra, per
        inceptos himenaeos. Suspendiße potenti. Quisque augü metus, hendrerit sit
        amet, commodo vel, scelerisque ut, ante. Präsent euismod euismod risus. Mauris
        ut metus sit amet mi cursus commodo. Morbi congü mauris ac sapien. Donec
        justo. Sed congü nunc vel mauris. Pellentesque vehicula orci id libero. In.

        ## VowelTransformation

        This file will check mutated_vowel_transformation

        Let's say we write a valid German word like: Klasse
        And a non valid word, which gets valid by transforming: Bücher

        ## picture path

        Test about picture path. ![my image alt text](#{Dir.pwd}/spec/test_set/ruby.png "opt title"). It's just a filename. After processing it's a path.
      EOF
      expect(File.read("#{ENV['PWD']}/spec/test_set_out/test_set.md")).to(eql(outputs))
    end
  end
end
