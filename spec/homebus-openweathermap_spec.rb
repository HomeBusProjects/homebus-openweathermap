require 'spec_helper'

require 'homebus-openweathermap/version'
require 'homebus-openweathermap/options'
require 'homebus-openweathermap/app'

require 'homebus/config'

class TestHomebusOpenweathermap < HomebusOpenweathermap::App
  # override config so that the superclasses don't try to load it during testing
  def initialize(options)
    @config = Hash.new
    @config = Homebus::Config.new

    @config.login_config = {
                            "default_login": 0,
                            "next_index": 1,
                            "homebus_instances": [
                                      {
                                        "provision_server": "https://homebus.org",
                                       "email_address": "example@example.com",
                                       "token": "XXXXXXXXXXXXXXXX",
                                       "index": 0
                                      }
                                    ]
    }

    @store = Hash.new
    super
  end
end

describe HomebusOpenweathermap do
  context "Version number" do
    it "Has a version number" do
      expect(HomebusOpenweathermap::VERSION).not_to be_nil
      expect(HomebusOpenweathermap::VERSION.class).to be String
    end
  end 
end

describe HomebusOpenweathermap::Options do
  context "Methods" do
    options = HomebusOpenweathermap::Options.new

    it "Has a version number" do
      expect(options.version).not_to be_nil
      expect(options.version.class).to be String
    end

    it "Uses the VERSION constant" do
      expect(options.version).to eq(HomebusOpenweathermap::VERSION)
    end

    it "Has a name" do
      expect(options.name).not_to be_nil
      expect(options.name.class).to be String
    end

    it "Has a banner" do
      expect(options.banner).not_to be_nil
      expect(options.banner.class).to be String
    end
  end
end

describe TestHomebusOpenweathermap do
  context "Methods" do
    options = HomebusOpenweathermap::Options.new
    app = HomebusOpenweathermap::App.new(options)

    it "Has a name" do
      expect(app.name).not_to be_nil
      expect(app.name.class).to be String
    end

    it "Consumes" do
      expect(app.consumes).not_to be_nil
      expect(app.consumes.class).to be Array
    end

    it "Publishes" do
      expect(app.publishes).not_to be_nil
      expect(app.publishes.class).to be Array
    end

    it "Has devices" do
      expect(app.devices).not_to be_nil
      expect(app.devices.class).to be Array
    end
  end
end
