#! /usr/bin/env ruby

require 'json'
require 'open-uri'

class Station
  attr_accessor :id, :name, :available_bikes, :available_docks, :broken_bikes
  def initialize(id, name)
    @id = id
    @name = name
    @available_bikes = 0
    @available_docks = 0
    @broken_bikes = 0
  end

  def update_from_feed(data)
    @available_bikes = data["availableBikes"]
    @available_docks = data["availableDocks"]
    @broken_bikes = data["totalDocks"] - data["availableBikes"] - data["availableDocks"]
  end

  def description
    bikes = fmt available_bikes
    docks = fmt available_docks
    reds = fmt broken_bikes
    "#{name}: #{bikes} bikes, #{docks} docks, #{reds} reds"
  end

  def fmt(i)
    i.to_s.rjust(2)
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
