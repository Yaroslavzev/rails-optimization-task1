# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

GC.disable

require_relative 'report/report'
require_relative 'report/parser'

class InitWork
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions = parse(file_lines)
    report = report(users, sessions)

    File.write('result.json', "#{report.to_json}\n")
  end
end
