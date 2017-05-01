# Overview

This application observe specified app crash rate from *fabric.io* and notify to *Slack*.

# Getting started

1. Install required Ruby gem packages

`bundle install --path vendor/bundle`

2. Generate config yml file for production

`cp sample.config.yml config.yml`

3. Fill your configuration in config.rb

```yml

fabric:
  group_name: example_inc
  device: {android/ios}
  package_name: com.example.android.app
  mail_address: info@example.com
  password: {your_password}
  version_name: "1.0.0"
  version_code: "100"
slack:
  incoming_url: "https://hooks.slack.com/services/xxxxx/yyyyyyy/zzzzzzzzz"
  channel: "#general"
  user_name: "CrashObserver"
  emoji: ":smile:"

```

4. Install Node package manage tool

`brew install npm`

5. Install phantomjs by npm

`npm install -g phantomjs`

# Usage

## Confirm execution

`bundle exec ruby src/access.rb`

## Cron execution

### Foreground

`bundle exec clockwork src/clock.rb`

### Background

`bundle exec nohup clockwork src/clock.rb &`


### For detail

Clockwork created by Adam Wiggins
https://github.com/adamwiggins/clockwork



