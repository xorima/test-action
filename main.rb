# built in
require 'json'
require 'logger'
require 'net/http'
require 'uri'

# 3rd party
require 'octokit'

# Setup logging
logging_level = ENV['Logging_level'] || 'Warn'
logger = Logger.new(STDOUT)
logger.level = logging_level

# We must have the github token to interact with the API and read the labels
github_token = ENV['GITHUB_TOKEN']
raise 'Set the GITHUB_TOKEN env variable' unless github_token

client = Octokit::Client.new(:access_token => github_token)

# Get the event that is passed in
github_event_path = ENV['GITHUB_EVENT_PATH']
logger.info("Getting event from #{github_event_path}")
file = File.open(github_event_path)
logger.debug('Parsing json from event')
event = JSON.parse(file.read)
file.close
logger.info('Event has been parsed as json')
logger.debug(event)

# Get information about the repository
logger.info('Getting information from github for this pull request')
pr_number = event['number']
repo_name = event['repository']['name']
owner = event['repository']['owner']['login']

repository_full_name = "#{owner}/#{repo_name}"

# get all the information in a single api call, api calls are limited after all.
pull_request = client.pull_request(repository_full_name, pr_number)
logger.info ('Checking if pull request is merged')
is_merged = pull_request.merged?

unless is_merged
  logger.warn('Only merged pull requests are processed, exiting')
  exit 0
end

logger.info('Repository has been merged, processing event')

logger.info('Checking if this Pull request was tagged as release')

unless pull_request.labels.detect { |l| l[:name] == 'release'}
  logger.warn('Only pull requests with the release label are processed, exiting')
  exit 0
end

payload_to_send = {
  pr_number: pr_number,
  repo_name: repo_name,
  owner: owner,
  }
  
endpoint_uri = ENV['ENDPOINT_URI']
logger.info("Sending event to #{endpoint_uri}")
uri = URI.parse(endpoint_uri)

header = {'Content-Type': 'text/json'}

# Create the HTTP objects
logger.debug('Creating the http object')
http = Net::HTTP.new(uri.host, uri.port)
logger.info('Creating http request object')
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = payload_to_send.to_json
logger.info('Sending the request')
response = http.request(request)
logger.info("request sent, status code is #{response.code}")

case response
when Net::HTTPSuccess
  logger.warn('Sucessful')
when Net::HTTPUnauthorized
  logger.error("error #{response.message}: username and password set and correct?")
  exit 1
when Net::HTTPServerError
  logger.error("error #{response.message}: try again later?")
  exit 2
else
  logger.error("error #{response.message}")
  exit 3
end
