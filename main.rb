# built in
require 'json'
require 'net/http'
require 'uri'

# 3rd party
require 'octokit'

# We must have the github token to interact with the API and read the labels
github_token = ENV['GITHUB_TOKEN']
raise 'Set the GITHUB_TOKEN env variable' unless github_token

client = Octokit::Client.new(:access_token => github_token)

# Get the event that is passed in
file = File.open(ENV['GITHUB_EVENT_PATH'])
event = JSON.load(file)
file.close

pr_number = event['number']
repo_name = event['repository']['name']
owner = event['repository']['owner']['login']

repository_full_name = "#{owner}/#{repo_name}"

# get all the information in a single api call, api calls are limited after all.
pull_request = client.pull_request(repository_full_name, pr_number)
is_merged = pull_request.merged?

puts (' bypassing merge check ')
# unless is_merged
#   puts(' We only process merged repositories ')
#   exit 0
# end

puts(' Processing ')

puts(pull_request.labels.count)
unless pull_request.labels.detect { |l| l[:name] == 'release'}
  abort (' No labels found ')
end

puts('releasing')
endpoint = ENV['ENDPOINT_URI']
puts(endpoint)
uri = URI.parse(endpoint)

header = {'Content-Type': 'text/json'}

# Create the HTTP objects
puts('http')
http = Net::HTTP.new(uri.host, uri.port)
puts('req')
request = Net::HTTP::Post.new(uri.request_uri, header)
puts('body')
request.body = event.to_json

# Send the request
if ENV['SEND']
  puts('sending')
  response = http.request(request)
end
puts('end')