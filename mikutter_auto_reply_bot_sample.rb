# -*- coding: utf-8 -*-

def selTopic(random, list)
    return list[random.rand(0..list.length - 1)]
end

Plugin.create(:mikutter_auto_reply_bot) do

    DEFINED_TIME = Time.new.freeze
    random = Random.new

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
            if m.message.to_s =~ /ひよわ.?(焼|やき)|ヒィヨォワァヤァキ|(h|H)iyowayaki|HIYOWAYAKI|Burned Hiyowa|ひよわ飯/ \
                    and m[:created] > DEFINED_TIME and !m.retweet? and !m.user.is_me?
                # select reply dic & get reply
                if m.message.to_s =~ /OR/
                    reply = selTopic(random, sql)
                elsif m.message.to_s =~ /--version|-v/
                    reply = selTopic(random, version)
                elsif m.message.to_s =~ /--help|-h/
                    reply = selTopic(random, help)
                elsif m.message.to_s =~ /飯|めし|meal/
                    reply = selTopic(random, meshi)
                else
                    reply = selTopic(random, default)
                end

                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
            if m.message.to_s =~ /ひよわヨドバ|ひよわ焼きヨドバ/ and m[:created] > DEFINED_TIME and !m.retweet?\
                    and !m.user.is_me?
                reply = selTopic(random, yodobashi)
                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
            if m.message.to_s =~ /ひよわbot.*(ping|飯)/ and m[:created] > DEFINED_TIME and !m.retweet? and m.user.is_me?
                if m.message.to_s =~ /ping/
                    reply = Time.new.to_s
                elsif m.message.to_s =~ /飯/
                    reply = selTopic(random, meshi)
                end
                # send reply
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
        end
    end
end
