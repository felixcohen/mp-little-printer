require 'sinatra'
require 'json'
require 'haml'
require 'data_mapper'

require './models.rb'
require './admin.rb'

# Prepares and returns this edition of the publication
#
# == Parameters:
# local_delivery_time
#   The time where the subscribed bot is.
# == Returns:
# HTML/CSS edition with etag.
#
get '/edition/' do
  return 400, 'Error: No local_delivery_time was provided' if params['local_delivery_time'].nil?
  return 400, 'Error: No lang was provided' if params['privatefeed'].nil?
  


  # Set the etag to be this content
  date = Time.parse(params['local_delivery_time'])
  etag Digest::MD5.hexdigest(date.strftime('%d%m%Y'))
  erb :publication
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


  # Set the etag to be this content
  #etag Digest::MD5.hexdigest(date.strftime('%d%m%Y'))
  erb :publication
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