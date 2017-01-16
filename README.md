# UIRecorder

UIRecorder is for parsing screen element sources and saving to a yml as a reference template, 
which helps for checking elements in automation test. 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uirecorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uirecorder

## Usage

* WDA:
```
require 'uirecorder'
require 'wda_lib'

wda_client = WDA.new(device_url: "#{YOUR_WDA_URL}")
wda_recorder = UIRecorder.new(driver: wda_client, 
                              exclude_type: ['Other'], 
                              skip_keyboard: false)
wda_recorder.record_page('app_screen_xx.yml')
```

* Customized page source file: (Specify file path to @driver)
```
require 'uirecorder'

customized_client = UIRecorder.new(driver: 'file_path', 
                                   exclude_type: ['Other', 'Window', 'StatusBar'],
                                   skip_keyboard: false)

customized_client.record_page('app_screen_xx.yml', parser = 'WDA')
```

## ToDo

1. Add appium page source parsing
2. Add selenium(mobile) page source parsing


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ymin/uirecorder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

