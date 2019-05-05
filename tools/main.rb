require_relative './credit_parser'
require_relative './cover_art_scraper'
require_relative './page_title_scraper'

# TODO: Stop instantiating these and make them static methods or something more
# appropriate and ruby-like.
cover_art_scraper = CoverArtScraper.new

tracks = CreditParser.new.get_info_for_file

cover_art_scraper.scrape(tracks)
PageTitleScraper.scrape(tracks)

File.open(__dir__ + '/../src/data.json', 'w') { |f| f.puts tracks.to_json }
