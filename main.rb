require 'json'
require 'logger'
require 'net/http'
require 'uri'

# require 'octokit'
require_relative 'lib/payload'

def logger
  logging_level = ENV['Logging_level'] || 'Debug'
  logger = Logger.new(STDOUT)
  logger.level = logging_level
end

# def github_client
#   github_token = ENV['GITHUB_TOKEN']
#   raise 'Set the GITHUB_TOKEN env variable' unless github_token
#   Octokit::Client.new(access_token: github_token)
# end

def event_json
  file = File.open(ENV['GITHUB_EVENT_PATH'])
  event = JSON.parse(file.read)
  file.close

  @logger.info('Event has been parsed as json')
  @logger.debug(event)
  event
end

@logger = logger
# client = github_client

# Get information about the repository
# @logger.info('Getting information from github for this pull request')
# pr_number = event['number']
# repo_name = event['repository']['name']
# owner = event['repository']['owner']['login']
# repository_full_name = "#{owner}/#{repo_name}"

# get all the information in a single api call, api calls are limited after all.
# pull_request = client.pull_request(repository_full_name, pr_number)
# @logger.info 'Checking if pull request is merged'
# is_merged = pull_request.merged?

# unless is_merged
#   logger.warn('Only merged pull requests are processed, exiting')
#   exit 0
# end

# @logger.info('Repository has been merged, processing event')

payload = event_json
send_payload(payload)

unless pull_request.labels.detect { |l| l[:name] == 'release' }
  @logger.warn('Only pull requests with the release label are processed, exiting')
  exit 0
end
