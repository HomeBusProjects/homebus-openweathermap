#!/usr/bin/env ruby

require './options'
require './app'

openweathermap_app_options = OpenWeatherMapHomebusAppOptions.new

openweathermap = OpenWeatherMapHomebusApp.new openweathermap_app_options.options
openweathermap.run!
