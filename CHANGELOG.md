## unrelase
- ダウンロードしたソースコードを/tmpに展開するようにしました

## [0.1.10] - 2022-06-05
- project_template/app.rb.erbを評価してapp.rbを生成するようになりました

## [0.1.9] - 2022-02-18
- Pbmenv.installにenable_pbm_cloudオプションを追加しました
- Pbmenv.installにuse_optionオプションを追加しました
  - また、 `pbmenv intall xxx --use` が使えるようになりました

## [0.1.8] - 2022-02-08
- 不具合修正

## [0.1.7] - 2022-01-11
- currentが存在しないときに、installを実行するとcurrentを貼るようにしました

## [0.1.6] - 2021-12-01
- Improve spec
- installコマンドでcurrentの張り替えをしないようにしました。currentの参照を変えるときはuseコマンドを使ってください

## [0.1.5] - 2021-11-16
- `/usr/share/pbm/shared/device_id` を作成するようにしました

## [0.1.4] - 2021-11-15

- `/usr/share/pbm/current/device_id` にシムリンクを作成するようにしました

## [0.1.3] - 2021-10-22

- help的な出力をする

## [0.1.2] - 2021-09-19

- Github Actionsを使う

## [0.1.1] - 2021-09-18

- installの引数にlatestという値を渡せるようにしました

## [0.1.0] - 2021-09-11

- Initial release
