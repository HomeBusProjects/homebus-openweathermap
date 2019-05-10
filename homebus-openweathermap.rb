#!/usr/bin/env ruby

require './options'
require './app'

openweathermap_app_options = OpenWeatherMapHomeBusAppOptions.new

openweathermap = OpenWeatherMapHomeBusApp.new openweathermap_app_options.options
openweathermap.run!
