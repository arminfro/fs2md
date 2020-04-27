# frozen_string_literal: true

RSpec.describe Fs2md do
  it 'has a version number' do
    expect(Fs2md::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end

  it 'should print test_set_0 to specific string' do
    cli         = Fs2md::Cli.new
    cli.options = { pandoc: {} }
    cli.print(File.join('spec', 'test_set_0'))
    outputs     = <<~EOF
      # Documents

      ## not empty folder


      This is a test file, it should be included in the test result.
      It should have the heading 'not empty folder'

      ### further down

      This is a test file, it should be included in the test result
      It should have the heading 'Further down'

    EOF
    expect(File.read("#{ENV['PWD']}/output/spec/test_set_0.md") === outputs)
  end
end
