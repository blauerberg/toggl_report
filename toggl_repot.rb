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

# get checkin/checkout time
check_out = DateTime.parse(details.first["end"]).to_time.utc.to_i
check_in = DateTime.parse(details.last["start"]).to_time.utc.to_i

# collect worktimes per project
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
puts ""

puts "# Details"
puts "```"
notes.each do |project, descriptions|
  project_title = "## #{project}"
  project_items = []
  project_worktime = 0
  descriptions.each do |k, v|
    project_worktime += v
    project_items << "- #{k}: #{v}分"
  end
  puts "#{project_title} (計#{project_worktime}分, #{((project_worktime.to_f/total_worktime.to_f) * 100).round}%)"
  puts project_items.join("\n")
  puts ""
end
puts "```"
puts ""

puts "# Time"
puts "```"
puts "- CheckIn/CheckOut: #{Time.at(check_in).to_datetime.strftime('%H:%M')} - #{Time.at(check_out).to_datetime.strftime('%H:%M')} (#{(check_out - check_in) / 60}分)"
puts "- Toggl上の集計時間: #{(total_worktime / 60.0).to_f.round(1)}時間 (#{total_worktime}分)"
puts "```"