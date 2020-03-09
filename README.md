# toggl_report

togglの[Report API V2](https://github.com/toggl/toggl_api_docs/blob/master/reports.md) を使って一日分の作業時間をプロジェクト・タスク毎に集計し、レポートの雛形を作成するrubyのスクリプトです。
個人での利用を目的に作成したので、実装はとても雑です。

集計・表示する内容は以下の通りです。
- プロジェクト毎のトータルの作業時間と作業の割合
- プロジェク毎の各エントリのdescriptionと作業時間
- 1日の合計作業時間
- チェックイン・チェックアウト時刻 (当日のエントリで `start` が一番小さいエントリと `end` が一番大きいエントリから判断)

## How to use

1. Download and setup credentials.
```
$ git clone https://github.com/blauerberg/toggl-report.git
$ cd toggl-report
$ bundle install

# put your credentials into .env.local
$ cp cp .env .env.local
# set your token of DigitalOcean
$ sed -i -e "s/API_TOKEN/{your api token}/" .env.local

# set your ssh key name of DigitalOcean
$ sed -i -e "s/WORKSPACE_ID/{your workspace id}/" .env.local
```

2. Create report! :slightly_smiling_face:
```
$ bundle exec ruby toggl_report.rb
2020-01-16 のレポートです。
# Summary

# Details
## misc (計30分, 50%)
- slack、メールチェック: 30分

# project X (計30分, 50%)
- coding: 30分

# Time
- CheckIn/CheckOut: 09:32 - 10:55 (83分)
- Toggl上の集計時間: 1.0時間 (60分)
```

## TODO
- 取得するエントリの期間を指定できるようにする
- レポートの出力をテンプレート化

## LICENSE

MIT