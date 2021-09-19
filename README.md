# Pbmenv
[![Ruby](https://github.com/splaplapla/pbmenv/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/splaplapla/pbmenv/actions/workflows/ruby.yml)

* https://github.com/splaplapla/procon_bypass_man のバージョンマネージャー
* Raspberry Pi OSでの実行を想定しています

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pbmenv'
```

## Usage
* pbmenv commands
    * pbmenv available_versions
    * pbmenv versions
    * pbmenv install $version
    * pbmenv uninstall $version
* API
    * Pbmenv.available_versions
        * https://github.com/splaplapla/procon_bypass_man/tags からバージョンのリストを取ってくる
    * Pbmenv.versions
        * /usr/share/pbm/#{version} を返す
    * Pbmenv.install(version)
        * https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz をダウンロードして、
        * /usr/share/pbm/#{version} に app.rb, pbm.servive, setting.yml を配備する
        * /usr/share/pbm/#{version} を /usr/share/pbm/current へのシムリンクを作成する
    * Pbmenv.uninstall(version)
        * /usr/share/pbm/current が削除対象だったら例外を投げる
        * /usr/share/pbm/#{version} を 削除する

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pbmenv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pbmenv/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development
* docker-compose build --no-cache 
* docker-compose run app bash
