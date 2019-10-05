require 'elephrame'
require 'open-uri'
require 'nokogiri'
require 'httpclient'

# Define the schedule, set at 12pm every day

dailyYokai = Elephrame::Bots::Periodic.new '0 12 * * *'

# Create the post logic

dailyYokai.run do |bot|

    # Follow the random URL redirection

  random = 'http://yokai.com/?redirect_to=random'

  # Gather the final URL

  httpc = HTTPClient.new
  resp = httpc.get(random)
  # Strip the unnecessary characters

  link = resp.header['Location'].to_s.tr('[]""','')

  # Pull the HTML from the final page

  html = Nokogiri.HTML(open(link))

  # Take the page title and strip the trailing substring to return only the name of the creature

  yokainame = Nokogiri::HTML.parse(open(link)).title.to_s.gsub(" | Yokai.com", "")

  # Download the image from the page. Since this is always the first image, use html.at

  imagesource =  html.at('img')['src']
  File.open("yokai.png", "wb") do |f|
    f.write(open(imagesource).read)
  end

  # Define the status to be posted

  status = "The Yōkai of the day is " + yokainame + ". #yokai #yokaioftheday\n \nArt and information by Matthew Meyer.\n" + "\n" + link

  bot.post(status, media: ['./yokai.png'])
end