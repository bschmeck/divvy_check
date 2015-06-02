#! /usr/bin/env ruby

require 'json'
require 'open-uri'

class Station
  attr_accessor :id, :name, :available_bikes, :available_docks
  def initialize(id, name)
    @id = id
    @name = name
    @available_bikes = 0
    @available_docks = 0
  end

  def update_from_feed(data)
    @available_bikes = data["availableBikes"]
    @available_docks = data["availableDocks"]
  end

  def description
    "#{name} has #{available_bikes} bikes and #{available_docks} open docks"
  end
end

stations = {
  48 => Station.new(48, "600w"),
  74 => Station.new(74, "Erie"),
  111 => Station.new(74, "Huron"),
  364 => Station.new(364, "Oak"),
}

while true do
  raw = open("http://www.divvybikes.com/stations/json").read
  json = JSON.parse raw
  station_data = json["stationBeanList"].each do |station_data|
    station = stations[station_data["id"]]
    next unless station

    station.update_from_feed(station_data)
  end

  station_list = stations.sort.map{|s| s[1] }
  puts "#{Time.now.strftime("%-I:%M%P")} | #{station_list.map(&:description).join(" | ")}"

  sleep 60
end
