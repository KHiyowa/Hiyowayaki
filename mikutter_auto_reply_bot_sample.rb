# -*- coding: utf-8 -*-

Plugin.create(:mikutter_auto_reply_bot_sample) do

    DEFINED_TIME = Time.new.freeze
    REPEAT = 10

    # load reply dictionaries
    begin
        default = YAML.load_file(File.join(__dir__, 'dic', 'default.yml'))
        meshi = YAML.load_file(File.join(__dir__, 'dic', 'meshi.yml'))
        sql = YAML.load_file(File.join(__dir__, 'dic', 'sql.yml'))
        version = YAML.load_file(File.join(__dir__, 'dic', 'version.yml'))
    rescue LoadError
        notice 'Could not load yml file'
    end

    on_appear do |ms|
        ms.each do |m|
            if m.message.to_s =~ /ひよわ.?焼|ヒィヨォワァヤァキ|ひよわやき|Hiyowayaki|hiyowayaki|HIYOWAYAKI|ひよわ飯/ \
                    and m[:created] > DEFINED_TIME and !m.retweet? and !m.user.is_me?
                # select reply dic & get sample reply
                if m.message.to_s =~ /OR/
                    reply = sql.sample
                elsif m.message.to_s =~ /--version|-v/
                    reply = version.sample
                elsif m.message.to_s =~ /飯|めし/
                    reply = meshi.sample
                else
                    reply = default.sample
                end

                # send reply & fav
                Service.primary.post(:message => "@#{m.user.idname} #{reply}", :replyto => m)
            end
        end
    end

end
