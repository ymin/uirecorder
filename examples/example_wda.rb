require './lib/uirecorder'
require 'wda_lib'

wda_client = WDA.new(device_url: "#{YOUR_WDA_URL}")
wda_recorder = UIRecorder.new(driver: wda_client, 
                              exclude_type: ['Other'], 
                              skip_keyboard: false)
wda_recorder.record_page('app_screen_xx.yml')

