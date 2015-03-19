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
end

stations = {
  48: Station.new(48, "600w"),
  74: Station.new(74, "Erie")
}

while true do
  raw = open("http://www.divvybikes.com/stations/json").read
  json = JSON.parse raw
  station_data = json["stationBeanList"].each{|station_data|
    station = stations[station_data["id"]]
    next unless station
    stations.map(&:id).include h["id"] }.each do |data|
    stations[data["id"]].update_from_feed(data)
  end
  puts "#{Time.now.strftime("%-I:%M%P")} #{station["stationName"]} has #{station["availableBikes"]} bikes and #{station["availableDocks"]} open slots."
  sleep 60
end
