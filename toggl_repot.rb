#!/usr/bin/env ruby

require "dotenv"
require "togglv8"

Dotenv.load(".env.local", ".env")

api_token = ENV["API_TOKEN"]
workspace_id = ENV["WORKSPACE_ID"]

report = TogglV8::ReportsV2.new(api_token: api_token)
report.workspace_id = workspace_id
pp report.details()