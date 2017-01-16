require './lib/uirecorder'

customized_client = UIRecorder.new(driver: "./examples/template.json", 
                                   exclude_type: ['Other'], 
                                   skip_keyboard: false)
customized_client.record_page('app_screen_xx.yml', parser = 'WDA')