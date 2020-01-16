#!/usr/bin/env ruby

class Report
  attr_accessor :day, :check_in, :check_out, :details

  def initialize(day)
    @day = day
    @details = []
  end

  def total_worktime
    @details.sum{ |detail| detail.worktime }
  end

  def add_detail(toggl_detail)
    unless @details
      @details.push(ReportDetail.new(toggl_detail))
    else
      existing_detail = get_detail_by(toggl_detail["project"], toggl_detail["description"])
      if existing_detail.empty?
        @details.push(ReportDetail.new(toggl_detail))
      else
        existing_detail[0].add_time(toggl_detail["start"], toggl_detail["end"])
      end
    end
  end

  def projects
    @details.collect {|detail| detail.project}.uniq
  end

  def project_worktime(project)
    @details.select {|detail|
      detail.project == project
    }.sum{ |detail| detail.worktime }
  end

  def project_worktime_percentage(project)
    ((project_worktime(project).to_f / total_worktime.to_f) * 100).round
  end

  def get_detail_by(project, description = nil)
    @details.select {|detail|
      detail.project == project and description.nil? ? true : detail.description == description
    }
  end

end

class ReportDetail
  attr_reader :project, :description, :worktime

  def initialize(toggl_detail)
    @project = toggl_detail["project"]
    @description = toggl_detail["description"]
    @worktime = ((Time.parse(toggl_detail["end"]) - Time.parse(toggl_detail["start"])) / 60).to_i
  end

  def add_time(start, finish)
    @worktime += ((Time.parse(finish) - Time.parse(start)) / 60).to_i
  end
end