# -*- coding: utf-8 -*-

Plugin.create(:mikutter_auto_reply_bot) do

  DEFINED_TIME = Time.new.freeze

  # load reply dictionaries
  begin
    default = YAML.load_file(File.join(__dir__, 'dic', 'default.yml'))
    meshi = YAML.load_file(File.join(__dir__, 'dic', 'meshi.yml'))
  rescue LoadError
    notice 'Could not load yml file'
  end

  on_appear do |ms|
    ms.each do |m|
      if m.to_s =~ /ひよわ飯/ and m[:created] > DEFINED_TIME and !m.retweet?# and !m.user.is_me?
        # select reply dic & get sample reply
        reply = meshi.sample

        # send reply
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)

      elsif  m.to_s =~ /(ひ|υ|ν)(よ|ょ)(わ|ゎ).?(焼|やき|ゃき)|ヒィヨォワァヤァキ|(h|H)iyowayaki|HIYOWAYAKI|Burned Hiyowa/ and m[:created] > DEFINED_TIME and !m.retweet? and !m.user.is_me?
        # select reply dic & get sample reply
        reply = default.sample

        # send reply
        Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
      end
    end
  end

end
