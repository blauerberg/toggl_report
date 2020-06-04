# toggl-report

togglの[Report API V2](https://github.com/toggl/toggl_api_docs/blob/master/reports.md) を使って一日分の作業時間をプロジェクト・タスク毎に集計し、レポートの雛形を作成するrubyのスクリプトです。
個人での利用を目的に作成したので、実装はとても雑です。

集計・表示する内容は以下の通りです。
- プロジェクト毎のトータルの作業時間と作業の割合
- プロジェク毎の各エントリのdescriptionと作業時間
- 1日の合計作業時間
- チェックイン・チェックアウト時刻 (当日のエントリで `start` が一番小さいエントリと `end` が一番大きいエントリから判断)

## How to use

### Run on the host OS

1. Download and setup credentials.
```
$ git clone https://github.com/blauerberg/toggl-report.git
$ cd toggl-report
$ bundle install

# Put your credentials into .env.local
$ cp cp .env .env.local

# Set your api token
$ sed -i -e "s/API_TOKEN/{your api token}/" .env.local

# Set your workspace id
# Workspace id is in the last part of the dashboard's URL.
# (ex. https://toggl.com/app/dashboard/me/123456)
$ sed -i -e "s/WORKSPACE_ID/{your workspace id}/" .env.local

# Set your Redmine ID
# Your Redmine ID is the number found at the end of your Redmine profile URL
# (ex. https://redmine.example.com/users/123)
$ sed -i -e "s/REDMINE_ID/{your Redmine id}/" .env.local
```

2. Create report! :slightly_smiling_face:
```
$ bundle exec ruby toggl_report.rb
2020-01-16 のレポートです。
# Summary
- アクティビティ: https://redmine.example.com/activity?user_id=123

# Details

## misc (計30分, 50%)
- slack、メールチェック: 30分

## project X (計30分, 50%)
- coding: 30分

# Time

- CheckIn/CheckOut: 09:32 - 10:55 (83分)
- Toggl上の集計時間: 1.0時間 (60分)
```

### Run on the Docker

```
$ git clone https://github.com/blauerberg/toggl-report.git
$ cd toggl-report
$ docker build -t toggl-report .
$ docker run --rm -e API_TOKEN="YOUR_API_TOKEN" -e WORKSPACE_ID="YOUR_WORKSPACE_ID" -e REDMINE_ID="YOUR_REDMINE_ID" toggl-report
```

### レポートの時刻に利用するタイムゾーンを指定する

ビルド時に `timezone` を [tz timezone](https://en.wikipedia.org/wiki/Tz_database) で指定してください。
指定しない場合は `Asia/Tokyo` が利用されます。

```
$ docker build --build-arg timezone="Asia/Bangkok" -t toggl-report .
```

## TODO
- 取得するエントリの期間を指定できるようにする
- レポートの出力をテンプレート化

## LICENSE

MIT
