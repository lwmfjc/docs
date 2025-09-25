#!/data/data/com.termux/files/usr/bin/bash

# 极简版输入法切换脚本

LATIN_IME="com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME"
TASKER_IME="net.dinglisch.android.taskerm/com.joaomgcd.taskerm.keyboard.InputMethodServiceTasker"

triggle(){
# 简单的切换逻辑
current_ime=$(su -c 'settings get secure default_input_method')
if [ "$current_ime" = "$LATIN_IME" ]; then
    toTasker
else
    toGboard
fi
}

toTasker(){
    su -c 'settings put secure default_input_method' "$TASKER_IME"
    echo "切换到 Tasker 输入法"
}

toGboard(){
    su -c 'settings put secure default_input_method' "$LATIN_IME"
    echo "切换到 Gboard"
}

if [ $1 == "tasker" ] ; then
	toTasker
elif [ $1 == "gboard" ] ; then
	toGboard
else 
 	triggle
fi
