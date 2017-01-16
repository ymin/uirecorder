require "spec_helper"
require 'yaml'

describe UIRecorder do
  it "has a version number" do
    expect(UIRecorder::VERSION).not_to be nil
  end

  it "get elements successfully parsed from yml file and saved to specific file" do
    File.delete('./app_screen_xx.yml') if File.exist?('./app_screen_xx.yml')
    customized_client = UIRecorder.new(driver: "./examples/template.yml", 
                                   exclude_type: ['Other'], 
                                   skip_keyboard: false)
    customized_client.record_page('app_screen_xx.yml', parser = 'WDA')
    expect(YAML.load_file('./app_screen_xx.yml')['element_count']).to eq(17)
  end

  it "get elements successfully parsed from json file and saved to specific file" do
    File.delete('./app_screen_xx.yml') if File.exist?('./app_screen_xx.yml')
    customized_client = UIRecorder.new(driver: "./examples/template.json", 
                                   exclude_type: ['Other'], 
                                   skip_keyboard: false)
    customized_client.record_page('app_screen_xx.yml', parser = 'WDA')
    expect(YAML.load_file('./app_screen_xx.yml')['element_count']).to eq(17)
  end
end
