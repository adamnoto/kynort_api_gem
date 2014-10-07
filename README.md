# Kynort

Kynort is a server endpoint designed to search/books flights and hotels.

Airlines that Kynort supports are (ordered alphabetically):

1. AirAsia
2. Citilink
3. Garuda Indonesia
4. Lion Air
5. Sriwijaya

You can visit [Kynort](http://kynort.aquiforth.com) to register and begin creating 
your own tour and travel website by capitalising our API.

## Installation

Add this line to your application's Gemfile:

    gem 'kynort'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kynort

You then need to register an app in Kynort. You need to create an account first,
and then register your application. Detail of this can be found in Kynort's documentation
on our official website.

After gaining secret key and app id, you then need to configure Kynort. Create Kynort.rb in your initializer folder:

    Kynort.setup do |config|
      # You can receive the APP key and APP secret by registering your APP on Kynort.
      # Kynort is a service offered by Aquiforth.
    
      # your APP Key here
      config.app_key = ENV["KYNORT_APPID"]
    
      # your APP secret here
      config.secret_key = ENV["KYNORT_SECRET"]
    end

## Usage

Before you can use any API endpoint, you will need to inform Kynort that you will perform
an API request. To do so:

    Kynort.new_request()

You can check the status of your request:

    Kynort.explain_request("your request GUID")



## Contributing

1. Fork it ( https://github.com/[my-github-username]/kynort/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
