require 'json'

require_relative './credit_parser'
require_relative './cover_art_scraper'
require_relative './page_title_scraper'

STDOUT.sync = true

# TODO: Stop instantiating these and make them static methods or something more
# appropriate and ruby-like.
cover_art_scraper = CoverArtScraper.new

tracks = CreditParser.new.get_info_for_file

data_filename = __dir__ + '/../src/assets/data.json'

# Copy already existing page titles so we don't scrape every time.
if File.exist? data_filename
  old_tracks = JSON.parse(File.read(data_filename, :encoding => 'utf-8'), :symbolize_names => true)
  old_tracks.each do |ot|
    matched_track = tracks.find { |t| t[:page] == ot[:page] }
    next unless matched_track
    matched_track[:page_title] = ot[:page_title]
    matched_track[:album_id] = ot[:album_id]
    matched_track[:track_id] = ot[:track_id]
  end
end

additions_file = File.read("#{__dir__}/../src/assets/additions.json", :encoding => 'utf-8')
additions = JSON.parse(additions_file, :symbolize_names => true)

additions.each do |a|
  track = tracks.find { |t| t[:page] == a[:page] }
  a.each_pair { |k, v| track[k] = v } if track
end

cover_art_scraper.scrape(tracks)
PageTitleScraper.scrape(tracks)

# Print problems
tracks.each do |t|
  problems = []
  problems.push "No track link\n" unless t[:track_link]
  problems.push "No page title\n" unless t[:page_title]
  problems.push "No page link\n" unless t[:page_link]
  problems.push "No artist\n" unless t[:artist]
  problems.push "No album\n" unless t[:album]
  problems.push "No album link\n" unless t[:album_link]
  problems.unshift "=======" unless problems.empty?

  if problems.length > 0
    puts problems
    puts t.inspect
  end
end

File.open(data_filename, 'w') do |f|
  f.puts JSON.dump(tracks)
end

