require 'homebus'

class OpenWeatherMapHomebusAppOptions < Homebus::Options
  def app_options(op)
  end

  def banner
    'HomeBus OpenWeatherMap weather collector'
  end

  def version
    '0.0.2'
  end

  def name
    'homebus-openweathermap'
  end
end
