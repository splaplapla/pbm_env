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
      * --use
        * そのまま/usr/share/pbm/currentディレクトリへのシンボリックリンクを貼ります
    * pbmenv use $version
    * pbmenv uninstall $version
    * pbmenv clean $version_size_to_keep
* API
    * Pbmenv.available_versions
        * https://github.com/splaplapla/procon_bypass_man/tags からバージョンのリストを取ってくる
    * Pbmenv.versions
        * /usr/share/pbm/#{version} を返す
    * Pbmenv.install(version)
        * https://github.com/splaplapla/procon_bypass_man/archive/refs/tags/v#{version}.tar.gz をダウンロードして、
        * /usr/share/pbm/#{version} に app.rb, pbm.servive, setting.yml を配備する
    * Pbmenv.use(version)
        * /usr/share/pbm/#{version} を /usr/share/pbm/current へのシムリンクを作成する
    * Pbmenv.uninstall(version)
        * /usr/share/pbm/current が削除対象だったら例外を投げる
        * /usr/share/pbm/#{version} を 削除する
    * Pbmenv.clean(version_size_to_keep)
        * 古いバージョンをversion_size_to_keepの数だけ削除します
        * currentと最新のディレクトリは削除対象外です

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pbmenv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pbmenv/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development
* docker-compose build --no-cache
* docker-compose run app bash
* bin/rspec
  * also `DISABLE_DEBUG_LOG=1 bin/rspec`

### ローカルでgemをインストールして動作確認をする
* rake build
* gem i --local pkg/pbmenv-x.y.z.gem
* pbmenv ...
