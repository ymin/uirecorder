#
# Created by Yi MIN<minsparky@gmail.com>
# Copyright © 2017 Yi MIN. All rights reserved.
#
Dir[File.dirname(__FILE__) + '/uirecorder/*.rb'].each {|file| require file }
require 'logger'
require 'yaml'
require 'digest'

class UIRecorder

# if ARGV[0].nil?
#   puts 'WDA url or Appium url:'
#   @wda_url = $stdin.gets.chomp
# else
#   puts "WDA url is: #{ARGV[0]}"
#   @wda_url = ARGV[0]
# end

  include ::UIRecorder::WDAUIParser
  
  attr_accessor :driver, :page_hash, :save_file_path, :skip_keyboard
  attr_accessor :exclude_element, :exclude_type, :element_count
  attr_reader   :keyboard_path

  def initialize(opts = {})
    @driver = opts.fetch :driver
    @driver_type = opts.fetch :driver_type, @driver.class  #Support WDA, later for Appium/Selenium
    @page_hash = opts.fetch :page_hash, nil
    @save_file_path = opts.fetch :save_file_path, nil
    @skip_keyboard = opts.fetch :skip_keyboard, true
    @exclude_type = opts.fetch :exclude_type, []
    @exclude_element = opts.fetch :exclude_element, {}
    @show_invisible_element = opts.fetch :show_invisible_element, false
    @show_inaccessible_element = opts.fetch :show_inaccessible_element, false  # Has bug, to be fixed in wda_lib
    @custom_page_file = opts.fetch :custom_page_file, './template.yml'
    @keyboard_path = ''
    @logger = Logger.new('./tmp/uirecorder.log', 0, 1 * 1024 * 1024) # Start the log over whenever the log exceeds 1 megabytes in size.
  end

  def init_tree_parser
    @parsed_nodes = Hash.new
    @children_tree = Array.new
    @parent_node = Array.new
    @children_node_index = 0
    @deep_level = 0
    @path = ''
    @parse_count = 1
    @total_elements_count = 0
    @saved_elements_count = 0
  end

  def current_page(visible = true, accessible = false)
    visible = !@show_invisible_element
    accessible = @show_inaccessible_element
    @logger.debug "Getting current page UI elements..."
    case @driver_type.to_s
    when 'WDA'
      begin
        page = @driver.source(nil, accessible, visible, wait_time = 180)
      rescue => e
        @logger.error "Failed to get current page's elements, error: #{e}"
      end
      page.delete('sessionId')
      page.delete('status')
      File.open('./tmp/page_elements_tmp.yml', 'wb') do |f|
        f.write(page.to_yaml)
      end
      return page
    when 'Appium'
    when 'Selenium'
    when 'String'
      begin
        page = YAML.load_file(@driver)
      rescue => e
        @logger.error "Failed to load page's elements from #{@driver}, error: #{e}"
      end        
      return page
    else 
    end
  end

  def new_suggested_name
    @suggested_name.nil?? use_element_label_as_screen_name : @suggested_name = "#{rand(1..100)}.yml"
  end

  def use_element_label_as_screen_name
    node_key = @parsed_nodes.keys.sample
    while @parsed_nodes[node_key]['label'].nil? && @parsed_nodes[node_key]['name'].nil?
      node_key = @parsed_nodes.keys.sample
    end
    @suggested_name = @parsed_nodes[node_key]['label'] || @parsed_nodes[node_key]['name']
    @suggested_name = @suggested_name.downcase.gsub(' ','_').gsub(',','').gsub('(#', '').gsub(')', '').gsub(/[\x00\/\\:\*\?\'\"<>\|\s]/, '_')
  end

  def next_page
  end

  def last_page
  end

  def check_status
    case @driver_type.to_s
    when 'WDA'
      return (@driver.status['status'] == 0)? true : false
    when 'Appium'
    when 'Selenium'
    else
      return true
    end
  end

  def refine_save_file_name
    while @save_file_path.nil?
      puts "You haven't given the name for this screen, does #{use_element_label_as_screen_name} sounds good for you?\n(Yes/No) or give yours:"
      input_name = $stdin.gets.chomp
      case input_name.downcase
      when 'yes', 'y'
        @save_file_path = @suggested_name
      when 'no', 'n'
        use_element_label_as_screen_name
      else 
        @save_file_path = input_name
      end
    end
  end
      
  def record_page(page_file_name = nil, parser = nil)
    if check_status
      @page_elements = current_page
      @driver_type = parser unless parser.nil?
      case @driver_type.to_s
      when 'WDA'
        init_tree_parser 
        @page_elements = @page_elements['value']['tree'] # Get elements tree
        wda_dup_node(@page_elements)
      when 'Appium'
      when 'Selenium'
      end
      page_hash = Digest::SHA256.hexdigest(@parsed_nodes.keys.join('/'))
      if !page_file_name.nil?
        @save_file_path = page_file_name
      else
        @save_file_path = refine_save_file_name
      end
      elements = Hash.new
      elements.merge!(
        'page_name' => File.basename(@save_file_path, '.*'),
        'page_hash' => page_hash, 
        'element_count' => @saved_elements_count,
        'total_elements_count' => @total_elements_count,
        'creation_date' => Time.now.strftime('%Y%m%d%H%M%S')
      )
      elements.merge!('elements' => @parsed_nodes)
      @logger.debug "Saving elements tree to #{page_file_name}"
      File.open(@save_file_path, 'wb') do |f|
        f.write(elements.to_yaml)
      end
      @logger.debug "Current page UI elements are saved in #{page_file_name}"
      return elements
    else
      @logger.debug "#{@driver_type} device is not available, please check it!"
      return nil
    end
  end
end
