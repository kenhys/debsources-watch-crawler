# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Analyze
          class Graph < Debsources::Watch::Crawler::Command
            def initialize(type, options)
              @type = type
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              output.puts "OK"
              generate_watch_version_pie_graph
              generate_watch_file_pie_graph
              generate_watch_host_top5_pie_graph
              generate_watch_host_top5all_pie_graph
              generate_watch_host_salsa_pie_graph
            end

            def setup_graph
              @graph = Gruff::Pie.new(600)
              @graph.title_font_size = 36
              @graph.zero_degree = -90
              @graph.sort = false
              @graph.show_values_as_labels = false
            end

            def generate_watch_version_pie_graph
              dataset = @pkgs.select do |record|
                record.watch_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_version")
              setup_graph
              @graph.title = "Grouping by debian/watch version"

              groups.each do |record|
                unless record._key == 0
                  @graph.data("version #{record._key} (#{record['_nsubrecs']})", [record["_nsubrecs"]])
                end
              end
              @graph.write("group-by-watch-version.png")
            end

            def generate_watch_file_pie_graph
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_missing")
              setup_graph
              @graph.title = "How many packages\nsupports debian/watch?"

              groups.each do |record|
                if record._key == 0
                  @graph.data("watch file (#{record["_nsubrecs"]})", record["_nsubrecs"])
                else
                  @graph.data("no watch file (#{record["_nsubrecs"]})", record["_nsubrecs"])
                end
              end
              @graph.write("group-by-watch-file.png")
            end

            def generate_watch_host_top5_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "Top 5 upstream hosting site"

              other_data = 0
              total = 0
              groups.each_with_index do |record, index|
                total += record["_nsubrecs"]
                if index < 5
                  @graph.data("#{record._key} (#{record['_nsubrecs']})", record["_nsubrecs"])
                else
                  other_data += record["_nsubrecs"]
                end
              end
              @graph.data("other (#{other_data})", [other_data])
              @graph.write("group-by-top5-hosting.png")
              p other_data
              p total
            end

            def generate_watch_host_top5all_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "Top 5 upstream hosting site"

              other_data = 0
              top5 = 0
              groups.each_with_index do |record, index|
                if index < 5
                  top5 += record["_nsubrecs"]
                else
                  other_data += record["_nsubrecs"]
                end
              end
              @graph.data("top 5 sites (#{top5})", top5)
              @graph.data("other (#{other_data})", [other_data])
              @graph.write("group-by-top5all-hosting.png")
            end

            def generate_watch_host_salsa_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              other_count = dataset.size
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "How many upstream use salsa.d.o?"

              salsa = groups.select do |record|
                record._key == "salsa.debian.org"
              end
              salsa.each do |record|
                p record["_nsubrecs"]
                @graph.data("salsa.d.o (#{record['_nsubrecs']})", record["_nsubrecs"])
              end
              @graph.data("other (#{other_count})", other_count)
              @graph.write("group-by-hosting-salsa.png")
            end
          end
        end
      end
    end
  end
end