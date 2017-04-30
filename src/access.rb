require 'nokogiri'
require 'capybara'
require 'rails_helper'
require 'slack-notifier'
require 'yaml'
require 'capybara/poltergeist'

$yaml = YAML.load_file("./config.yml")

def print_crash_info

  session = create_logind_session($yaml["fabric"]["mail_address"], $yaml["fabric"]["password"])
  session = go_to_android(session)

  title = "*Android Fabric Info (All versions)*\n"
  free_text =  "Crash free user rate : #{parse_crash_free_user_rate(session)}\n"
  session_text = "Crash free session rate : #{parse_crash_free_session_rate(session)}"
  merged_text = title + free_text + session_text

  puts merged_text
  notify_to_slack(merged_text)
end  

def print_latest_crash_info

  session = create_logind_session($yaml["fabric"]["mail_address"], $yaml["fabric"]["password"])
  session = go_to_android(session, $yaml["fabric"]["version_name"], $yaml["fabric"]["version_code"])

  title = "*Android Fabric Info (#{$yaml["fabric"]["version_name"]})*\n "
  free_text = "Crash free user rate : #{parse_crash_free_user_rate(session)}\n"
  session_text = "Crash free session rate : #{parse_crash_free_session_rate(session)}"
  
  merged_text = title + free_text + session_text
  notify_to_slack(merged_text)
end  

def create_logind_session(email, password)

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 })
  end

  Capybara.default_selector = :css
  Capybara.app_host = "https://www.fabric.io"

  session = Capybara::Session.new(:poltergeist)
  session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87" } 
  session.visit "/login"

  session.within("div.i_sign-in") do
    session.fill_in id:'email', with:  email
    session.fill_in id:'password', with: password
  end
  
  session.find('#l_sdk-chrome > div.relative.stage > div:nth-child(1) > div > form > button').click
  sleep 3

  return session
end


def go_to_android(session, version_name = "", version_code = "")

  path = "/eureka-inc/android/apps/jp.eure.android.pairs/issues?time=last-seven-days&event_type=all&subFilter=state&state=open"

  if(version_name.length > 0) then
    path += "&build%5B0%5D=#{version_name}%20%28#{version_code}%29"
  end
  

  session.visit(path)
  sleep 6

  return session
end 

def parse_crash_free_user_rate(session)
  doc = Nokogiri::HTML.parse(session.html)
  crash_free_user_rate = doc.css('#l_dashboard > article > div.flex-1.flex-box > section > div > div > div.header-wrap > div.issues_metrics > div.stat-row.flex-box.top-bar > div > span > div:nth-child(1) > div > div.value > span:nth-child(1)').text
  return crash_free_user_rate
end

def parse_crash_free_session_rate(session)
  doc = Nokogiri::HTML.parse(session.html)
  crash_free_session_rate = doc.css('#l_dashboard > article > div.flex-1.flex-box > section > div > div > div.header-wrap > div.issues_metrics > div.stat-row.flex-box.top-bar > div > span > div:nth-child(2) > div > div.value > span').text
  return crash_free_session_rate
end

def notify_to_slack(text) 
  slack = Slack::Notifier.new $yaml["slack"]["incoming_url"] do
   defaults channel: $yaml["slack"]["channel"], 
            username: $yaml["slack"]["user_name"]
  end
  slack.post text: text, icon_emoji: $yaml["slack"]["emoji"]
end

print_latest_crash_info
print_crash_info