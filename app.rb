# coding: utf-8
require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'net/http'
require 'dotenv'
require 'json'

class OpenWeatherMapHomeBusApp < HomeBusApp
  DDC = 'org.homebus.experimental.weather'

  def initialize(options)
    @options = options

    super
  end

  def setup!
    Dotenv.load('.env')
    @latitude = ENV['LATITUDE']
    @longitude = ENV['LONGITUDE']
    @openweathermap_appid = ENV['OPENWEATHERMAP_APPID']
  end

  def update_delay
    60*15
  end

  def K_to_C(temp)
    temp - 273.15
  end

  def rewrite_current(conditions)
    { 
      temperature: ("%0.2f" % K_to_C(conditions[:main][:temp])).to_f,
      humidity:  conditions[:main][:humidity],
      pressure: conditions[:main][:pressure],
      visibility: conditions[:visibility],
      wind: conditions[:wind],
      rain: conditions[:rain],
      conditions_short: conditions[:weather][0][:main],
      conditions_long: conditions[:weather][0][:description]
    }
  end

  # forecast samples: https://samples.openweathermap.org/data/2.5/forecast?lat=35&lon=139&appid=b6907d289e10d714a6e88b30761fae22
  # https://openweathermap.org/forecast5
  def rewrite_forecast(forecast)
    {
      days: 1,
      forecast: [
      ]
    }
  end

  def _get_weather
    begin
      response = Net::HTTP.get_response('api.openweathermap.org', "/data/2.5/weather?lat=#{@latitude}&lon=#{@longitude}&APPID=#{@openweathermap_appid}")
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

    if conditions
      publish! DDC, rewrite_current(conditions)
    end
  
#### Forecast JSON currently exceeds the indexing abilities of the database, so don't bother for now
if false
    response = Net::HTTP.get_response('api.openweathermap.org', "/data/2.5/forecast?lat=#{ENV['LATITUDE']}&lon=#{ENV['LONGITUDE']}&APPID=#{ENV['OPENWEATHERMAP_APPID']}")
    if response.is_a?(Net::HTTPSuccess)
      forecast = JSON.parse response.body

      timestamp = Time.now.to_i
      @mqtt.publish '/weather/forecast', JSON.generate({ id: @uuid,
                                                         timestamp: timestamp,
                                                         forecast: forecast
                                                       })
    else
      puts "ERROR #{response.message}"
      @matt.publish '/weather/$error', JSON.generate({ id: @uuid,
                                                      timestamp: timestamp,
                                                      message: response.message})
    end
end

    sleep update_delay
  end

  def manufacturer
    'HomeBus'
  end

  def model
    'OpenWeatherMap'
  end

  def friendly_name
    'Weather conditions and forecast'
  end

  def friendly_location
    'Portland, OR'
  end

  def serial_number
    "#{@latitude}-#{@longitude}"
  end

  def pin
    ''
  end

  def devices
    [
      { friendly_name: 'Weather conditions',
        friendly_location: 'Portland, OR',
        update_frequency: update_delay,
        index: 0,
        accuracy: 0,
        precision: 0,
        wo_topics: [ DDC ],
        ro_topics: [],
        rw_topics: []
      }
    ]
  end
end
