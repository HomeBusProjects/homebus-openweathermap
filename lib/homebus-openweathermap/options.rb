require 'homebus'
require 'homebus-openweathermap/version'

class HomebusOpenweathermap::Options < Homebus::Options
  def app_options(op)
  end

  def banner
    'HomeBus OpenWeatherMap weather collector'
  end

  def version
    HomebusOpenweathermap::VERSION
  end

  def name
    'homebus-openweathermap'
  end
end
