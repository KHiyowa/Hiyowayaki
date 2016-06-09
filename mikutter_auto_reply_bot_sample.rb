# -*- coding: utf-8 -*-

Plugin.create(:mikutter_auto_reply_bot_sample) do

    DEFINED_TIME = Time.new.freeze
    REPEAT = 10

    # load reply dictionaries
    begin
        default = YAML.load_file(File.join(__dir__, 'dic', 'default.yml'))
        sql = YAML.load_file(File.join(__dir__, 'dic', 'sql.yml'))
        version = YAML.load_file(File.join(__dir__, 'dic', 'version.yml'))
        help = YAML.load_file(File.join(__dir__, 'dic', 'help.yml'))
        meshi = YAML.load_file(File.join(__dir__, 'dic', 'meshi.yml'))
        yodobashi = YAML.load_file(File.join(__dir__, 'dic', 'yodobashi.yml'))
    rescue LoadError
        notice 'Could not load yml file'
    end

    on_appear do |ms|
        ms.each do |m|
            if m.message.to_s =~ /ひよわ.?(焼|やき)|ヒィヨォワァヤァキ|(h|H)iyowayaki|HIYOWAYAKI|ひよわ飯/ \
                    and m[:created] > DEFINED_TIME and !m.retweet? and !m.user.is_me?
                # select reply dic & get sample reply
                if m.message.to_s =~ /OR/
                    reply = sql.sample
                elsif m.message.to_s =~ /--version|-v/
                    reply = version.sample
                elsif m.message.to_s =~ /--help|-h/
                    reply = help.sample
                elsif m.message.to_s =~ /飯|めし/
                    reply = meshi.sample
                else
                    reply = default.sample
                end

                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
            if m.message.to_s =~ /ひよわヨドバ|ひよわ焼きヨドバ/ and m[:created] > DEFINED_TIME and !m.retweet?\
                    and !m.user.is_me?
                reply = yodobashi.sample
                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
            if m.message.to_s =~ /ひよわbot.*(ping|飯)/ and m[:created] > DEFINED_TIME and !m.retweet? and m.user.is_me?
                if m.message.to_s =~ /ping/
                    reply = Time.new.to_s
                elsif m.message.to_s =~ /飯/
                    reply = meshi.sample
                end
                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
        end
    end
end
