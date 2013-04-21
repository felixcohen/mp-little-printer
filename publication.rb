require 'sinatra'
require 'json'
require 'date'
require 'open-uri'
require 'rexml/document'

# Prepares and returns this edition of the publication
#
# == Parameters:
# privatefeed
#   The private URL for this user's google calendar
# local_delivery_time
#   The time where the subscribed bot is.
# == Returns:
# HTML/CSS edition with etag.
#
get '/edition/' do
  return 400, 'Error: No local_delivery_time was provided' if params['local_delivery_time'].nil?
  return 400, 'Error: No lang was provided' if params['privatefeed'].nil?
  
  # Extract configuration provided by user through BERG Cloud. These options are defined by the JSON in meta.json.
  privatefeed = params['privatefeed'];
  
  # Set the etag to be this content. This means the user will not get the same content twice, 
  # but if they reset their subscription (with, say, a different language they will get new content 
  # if they also set their subscription to be in the future)
  etag Digest::MD5.hexdigest(date.strftime('%d%m%Y'))
  
  # Build this edition.
  @greeting = ""
  url = privatefeed + "?singleevents=true&orderby=starttime&sortorder=ascending"
  # actually, just get today's events
  today = Date.today.strftime('%Y-%m-%dT%H:%M:%S')
  tomorrow = (Date.today+1).strftime('%Y-%m-%dT%H:%M:%S')
  url = url + '&start-min=' + today
  url = url + '&start-max=' + tomorrow

  xml_data = ""
  
  open(url) do |f|
    xml_data = f.read
  end
  doc = REXML::Document.new(xml_data)
  titles = []
  content = []
  shortdate = []
  location = []
  doc.elements.each('feed/entry/title'){ |e| titles << e.text }
  doc.elements.each('feed/entry/content'){ |e| content << e.text }
  doc.elements.each('feed/entry/content'){ |e| 
    whentokens = e.text.split("\n").first.split
    if whentokens[5] == "/>" # this happens when it's an all day event
      # TODO: this is grim. Use JSON/iCal instead and refactor?
      shortdate << "All day ---"
    else
      shortdate << whentokens[5] + "-" + whentokens[7].to_s.slice(0..4) 
      # NB: urgh. Why isn't strip removing this final whitespace? Forcing it with a slice of ignorance
    end                                          
  }
  doc.elements.each('feed/entry/content'){ |e| location << e.text.split("\n").find_all {|i| i.include?("Where: ")}}

  titles.each_with_index do |title, idx|
    line = (shortdate[idx] + " " + title)[0, 64]
    @greeting += line
    if (location[idx].first) 
      line2 = ("            (" + location[idx].first.slice(13..-1) + ")")[0, 64]
      @greeting +=  line2
    end
  end

  @greeting += "\n"

  # Set the etag to be this content
  date = Time.parse(params['local_delivery_time'])
  etag Digest::MD5.hexdigest(date.strftime('%d%m%Y'))
  erb :hello_world
end


# Returns a sample of the publication. Triggered by the user hitting 'print sample' on you publication's page on BERG Cloud.
#
# == Parameters:
#   None.
#
# == Returns:
# HTML/CSS edition with etag. This publication changes the greeting depending on the time of day. It is using UTC to determine the greeting.
#
get '/sample/' do
  @greeting = "<h1>Where are you supposed to be today?</h1>"

  url = "https://www.google.com/calendar/feeds/roo.reynolds%40digital.cabinet-office.gov.uk/private-ef8146bf0bee5149c2748a89078badc6/basic"
  url = url + "?singleevents=true&orderby=starttime&sortorder=ascending"
  # actually, just get today's events
  today = Date.today.strftime('%Y-%m-%dT%H:%M:%S')
  tomorrow = (Date.today+1).strftime('%Y-%m-%dT%H:%M:%S')
  url = url + '&start-min=' + today
  url = url + '&start-max=' + tomorrow

  xml_data = ""
  
  open(url) do |f|
    xml_data = f.read
  end
  doc = REXML::Document.new(xml_data)
  titles = []
  content = []
  shortdate = []
  location = []
  doc.elements.each('feed/entry/title'){ |e| titles << e.text }
  doc.elements.each('feed/entry/content'){ |e| content << e.text }
  doc.elements.each('feed/entry/content'){ |e| 
    whentokens = e.text.split("\n").first.split
    if whentokens[5] == "/>" # this happens when it's an all day event
      # TODO: this is grim. Use JSON/iCal instead and refactor?
      shortdate << "All day"
    else
      shortdate << whentokens[5] + "-" + whentokens[7].to_s.slice(0..4) 
      # NB: urgh. Why isn't strip removing this final whitespace? Forcing it with a slice of ignorance
    end                                          
  }
  doc.elements.each('feed/entry/content'){ |e| location << e.text.split("\n").find_all {|i| i.include?("Where: ")}}

  titles.each_with_index do |title, idx|
    line = ("<small><strong>" + shortdate[idx] + "</strong></small><br/>" + title)[0, 80]
    @greeting += "<p>#{line}"
    if (location[idx].first) 
      line2 = (location[idx].first.slice(13..-1))[0, 80]
      @greeting += "<br/><small>#{line2}<small>"
      open(URI::encode("http://where.yahooapis.com/geocode?q=" + line2)) do |f|
        xml_data = f.read
      end
      doc = REXML::Document.new(xml_data)
      latitude = ""
      longitude = ""
      doc.elements.each('ResultSet/Result/latitude'){|e| latitude = e.text}
      doc.elements.each('ResultSet/Result/longitude'){|e| longitude = e.text}

      #p doc.each['longitude'][0]
      @greeting += "<br/><img src='http://maps.googleapis.com/maps/api/staticmap?center=" + latitude + "," + longitude + "&zoom=17&size=384x384&sensor=false' class='dither'>"
    end
    @greeting += "</p>"
  end
  @greeting += "\n<hr>"

  # Set the etag to be this content
  #etag Digest::MD5.hexdigest(date.strftime('%d%m%Y'))
  erb :hello_world
end


# Returns a sample of the publication. Triggered by the user hitting 'print sample' on you publication's page on BERG Cloud.
#
# == Parameters:
# :config
#   params[:config] contains a JSON array of responses to the options defined by the fields object in meta.json.
#   in this case, something like:
#   params[:config] = ["name":"SomeName", "lang":"SomeLanguage"]
#
# == Returns:
# a response json object.
# If the paramters passed in are valid: {"valid":true}
# If the paramters passed in are not valid: {"valid":false,"errors":["No name was provided"], ["The language you chose does not exist"]}"
#
post '/validate_config/' do
  response = {}
  response[:errors] = []
  response[:valid] = true
  
  # Extract config from POST
  user_settings = JSON.parse(params[:config])

  # If the user did choose a language:
  if user_settings['lang'].nil?
    response[:valid] = false
    response[:errors].push('Please select a language from the select box.')
  end
  
  # If the user did not fill in the name option:
  if user_settings['name'].nil?
    response[:valid] = false
    response[:errors].push('Please enter your name into the name box.')
  end
  
  unless greetings.include?(user_settings['lang'].downcase)
    # Given that that select box is populated from a list of languages that we have defined this should never happen.
    response[:valid] = false
    response[:errors].push("We couldn't find the language you selected (#{config["lang"]}) Please select another")
  end
  
  content_type :json
  response.to_json
end