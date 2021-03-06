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
    reds = fmt broken_bikes, 1
    "#{name}: #{bikes} . #{docks} . #{reds}"
  end

  def fmt(i, digits = 2)
    i.to_s.rjust(digits)
  end
end

def get_station_data
  raw = open("https://feeds.divvybikes.com/stations/stations.json").read
  json = JSON.parse raw
  yield json
rescue Exception => e
  puts "Err: #{e.class}"
  nil
end

stations = {
  111 => Station.new(111, "Sedgwick"),
  74 => Station.new(74, "Erie"),
  53 => Station.new(53, "Wells"),
  212 => Station.new(212, "Orleans")
}

while true do
  get_station_data do |json|
    station_data = json["stationBeanList"].each do |station_data|
      station = stations[station_data["id"]]
      next unless station

      station.update_from_feed(station_data)
    end

    station_list = stations.sort.map{|s| s[1] }
    puts "#{Time.now.strftime("%_I:%M%P")} | #{station_list.map(&:description).join(" | ")}"
  end

  sleep 60
end
