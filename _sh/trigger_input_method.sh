#!/data/data/com.termux/files/usr/bin/bash

# 极简版输入法切换脚本
# 输入法查询  su -c "ime list -s"

LATIN_IME="com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME"
TASKER_IME="net.dinglisch.android.taskerm/com.joaomgcd.taskerm.keyboard.InputMethodServiceTasker"
LY_EMPTY_IME="com.ly.inputmethod/.EmptyInputMethodService"
WEIXIN_IME="com.tencent.wetype/.plugin.hld.WxHldService"

# triggle(){
# # 简单的切换逻辑
# current_ime=$(su -c 'settings get secure default_input_method')
# if [ "$current_ime" = "$LATIN_IME" ]; then
#     toTasker
# else
#     toGboard
# fi
# }

toTasker(){
    su -c 'settings put secure default_input_method' "$TASKER_IME"
    echo "切换到 Tasker 输入法"
}

toLyEmpty(){
    su -c 'settings put secure default_input_method' "$LY_EMPTY_IME"
    echo "切换到 空白 输入法"
}

toWeixin(){
    su -c 'settings put secure default_input_method' "$WEIXIN_IME"
    echo "切换到 微信 输入法"
}

toGboard(){
    su -c 'settings put secure default_input_method' "$LATIN_IME"
    echo "切换到 Gboard"
}

if [[ $1 == "tasker" ]]; then
	toTasker
elif [[ $1 == "gboard" ]]; then
    toGboard
elif [[ $1 == "lyempty" ]]; then
    toLyEmpty
elif [[ $1 == "weixin" ]]; then
    toWeixin
fi
