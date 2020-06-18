#!/usr/bin/env ruby

require "time"
require "dotenv"
require "togglv8"
require 'optparse'
require File.dirname(__FILE__) + "/report"

Dotenv.load(".env.local", ".env")

api_token = ENV["API_TOKEN"]
workspace_id = ENV["WORKSPACE_ID"]
options = {}
opt_parser = OptionParser.new

opt_parser.new.on("-b", "--apply-standatd-break-time", "Apply standard break time in Japan") {|v| options[:forcebreak] = true }
opt_parser.parse!(ARGV)

me = TogglV8::API.new(api_token).me
toggl = TogglV8::ReportsV2.new(api_token: api_token)
toggl.workspace_id = workspace_id

now = Time.now
details = toggl.details(
  '',
  {
    user_ids: me["id"],
    since: now.strftime("%Y-%m-%d"),
    until: (Time.at(now.to_i + 86400)).strftime("%Y-%m-%d")
  }
)

if details.empty?
  STDERR.puts "Entry not found"
  exit -1
end

# get checkin/checkout time
check_out = DateTime.parse(details.first["end"]).to_time.utc.to_i
check_in = DateTime.parse(details.last["start"]).to_time.utc.to_i

report = Report.new(now, options)
report.check_in = check_in
report.check_out = check_out

details.each do |detail|
  detail = report.add_detail(detail)
end

# So, Let's create report!
puts "#{report.day.strftime("%Y-%m-%d")} のレポートです。"
puts ""
puts "# Summary"
puts ""

puts "# Details"
puts ""
puts "```"
report.projects.each_with_index do |project, i|
  project_items = []
  report.get_detail_by(project).each do |detail|
    project_items << "- #{detail.description}: #{detail.worktime}分"
  end
  puts "## #{project || 'No Project'} (計#{report.project_worktime(project)}分, #{report.project_worktime_percentage(project)}%)"
  puts project_items.join("\n")
  puts "" if i < report.projects.size - 1
end
puts "```"
puts ""

puts "# Time"
puts ""
puts "```"
puts "- CheckIn/CheckOut: #{Time.at(report.check_in).to_datetime.strftime('%H:%M')} - #{Time.at(report.check_out).to_datetime.strftime('%H:%M')} (#{report.total_check_time}分)"
puts "- Toggl上の集計時間: #{(report.total_worktime / 60.0).ceil(1)}時間 (#{report.total_worktime}分)"
puts "```"
