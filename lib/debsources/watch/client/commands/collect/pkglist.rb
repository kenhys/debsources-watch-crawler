# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Client
      module Commands
        class Collect
          class Pkglist < Debsources::Watch::Client::Command
            def initialize(options)
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              output.puts "OK"
            end
          end
        end
      end
    end
  end
end