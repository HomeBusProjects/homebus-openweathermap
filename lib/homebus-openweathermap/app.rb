# coding: utf-8
require 'homebus'
require 'dotenv'

require 'net/http'
require 'json'

class HomebusOpenweathermap::App < Homebus::App
  DDC_CURRENT = 'org.homebus.experimental.weather'
  DDC_FORECAST = 'org.homebus.experimental.weather-forecast'
  DDC_UVINDEX = 'org.homebus.experimental.uv-light-sensor'

  def initialize(options)
    @options = options

    super
  end

  def setup!
    Dotenv.load('.env')

    @location = ENV['LOCATION']
    @latitude = ENV['LATITUDE']
    @longitude = ENV['LONGITUDE']
    @openweathermap_appid = ENV['OPENWEATHERMAP_APPID']

    @device = Homebus::Device.new  name: "Weather conditions for #{@location}",
                                   manufacturer: 'Homebus',
                                   model: 'Openweathermap publisher',
                                   serial_number: "#{@location}"
  end

  def update_interval
    60*15
  end

  def K_to_C(temp)
    temp - 273.15
  end

  def rewrite_current(conditions)
    { 
      temperature: ("%0.2f" % K_to_C(conditions[:current][:temp])).to_f,
      humidity:  conditions[:current][:humidity],
      pressure: conditions[:current][:pressure],
      visibility: conditions[:current][:visibility],
      wind: conditions[:current][:wind_speed],
      rain: conditions[:current][:rain],
      conditions_short: conditions[:current][:weather][0][:main],
      conditions_long: conditions[:current][:weather][0][:description]
    }
  end

  def rewrite_uv(conditions)
    { 
      uvindex: conditions[:current][:uvi]
    }
  end

  def rewrite_uv_forecast(conditions)
    days = forecast[:daily].map { |day| day[:uvi] }

    {
      forecast: days
    }
  end

  # forecast samples: https://samples.openweathermap.org/data/2.5/onecall?lat=35&lon=139&appid=b6907d289e10d714a6e88b30761fae22
  # https://openweathermap.org/forecast5
  def rewrite_forecast(forecast)
    days = conditions[:daily].ap { |day| rewrite_current day }

    {
      days: days.length,
      forecast: days
    }
  end

  def _get_weather
    begin
      response = Net::HTTP.get_response('api.openweathermap.org', "/data/2.5/onecall?lat=#{@latitude}&lon=#{@longitude}&exclude=minutely,hourly&APPID=#{@openweathermap_appid}")
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse response.body, symbolize_names: true
      else
        nil
      end
    rescue
      nil
    end
  end

  def work!
    conditions = _get_weather
pp conditions
pp rewrite_current(conditions)
pp rewrite_forecast(conditions)
pp rewrite_uv(conditions)

    if conditions
      @device.publish! DDC_CURRENT, rewrite_current(conditions)
      @device.publish! DDC_UVINDEX, rewrite_uv(conditions)
    end
  
#### Forecast JSON currently exceeds the indexing abilities of the database, so don't bother for now
if false
    response = Net::HTTP.get_response('api.openweathermap.org', "/data/2.5/forecast?lat=#{ENV['LATITUDE']}&lon=#{ENV['LONGITUDE']}&APPID=#{ENV['OPENWEATHERMAP_APPID']}")
end

    sleep update_interval
  end

  def name
    'OpenWeathermap publisher'
  end

  def publishes
    [ DDC_CURRENT, DDC_UVINDEX ]
  end

  def devices
    [ @device ]
  end
end
