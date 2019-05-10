require 'homebus_app_options'

class OpenWeatherMapHomeBusAppOptions < HomeBusAppOptions
  def app_options(op)
  end

  def banner
    'HomeBus OpenWeatherMap weather collector'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-openweathermap'
  end
end
