#!/usr/bin/env ruby

require "time"
require "dotenv"
require "togglv8"

Dotenv.load(".env.local", ".env")

api_token = ENV["API_TOKEN"]
workspace_id = ENV["WORKSPACE_ID"]

report = TogglV8::ReportsV2.new(api_token: api_token)
report.workspace_id = workspace_id

now = Time.now
details = report.details(
  '',
  {
    since: Time.now.strftime("%Y-%m-%d"),
    until: (Time.at(Time.now.to_i + 86400)).strftime("%Y-%m-%d")
  }
)
notes = {}
total_worktime = 0

details.each do |detail|
  project = detail["project"]
  description = detail["description"]
  worktime = Time.parse(detail["end"]) - Time.parse(detail["start"])
  worktime = (worktime / 60).to_i

  unless notes.has_key?(project)
    notes[project] = {}
    notes[project][description] = worktime
  else
    unless notes[project].has_key?(description)
      notes[project][description] = worktime
    else
      notes[project][description] += worktime
    end
  end

  total_worktime += worktime
end

# So, Let's create report!

puts "#{Time.now.strftime("%Y-%m-%d")} のレポートです。"
puts "# Summary"
puts "- 本日の稼働時間: #{(total_worktime / 60.0).to_f.round}時間 (#{total_worktime}分)"
puts "- "
puts "- "
puts ""

puts "# Details"
notes.each do |project, descriptions|
  puts "## #{project}"
  descriptions.each do |k, v|
    puts "- #{k}: #{v}分"
  end
  puts ""
end