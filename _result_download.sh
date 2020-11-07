#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

#------------------------------------------------------------------
# 大会番号、ラウンド番号の定義確認、設定

RESULT_NO=$1
RESULT_ADDR_NO=$(($1 + 1))
ROUND_NO=$2

cd ./data/orig/

mkdir ./result
mkdir ./result_charalist
mkdir ./result_battlelist
mkdir ./rule
mkdir ./rule/skill_list

wget -O ./result/${RESULT_ADDR_NO}.html http://133.130.112.98/trialarea/result/${RESULT_ADDR_NO}
sleep 2
wget -O ./result_charalist/${RESULT_ADDR_NO}_${ROUND_NO}.html http://133.130.112.98/trialarea/result_charalist/${RESULT_ADDR_NO}/${ROUND_NO}
sleep 2
wget -O ./result_battlelist/${RESULT_ADDR_NO}_${ROUND_NO}.html http://133.130.112.98/trialarea/result_battlelist/${RESULT_ADDR_NO}/${ROUND_NO}
sleep 2

if [ ! -s ./rule/skill_list/${RESULT_ADDR_NO}.html ] && [ ! -s ./battle/${RESULT_ADDR_NO}.html.gz ]; then
    wget -O ./rule/skill_list/${RESULT_ADDR_NO}.html http://133.130.112.98/trialarea/rule/skill_list
    sleep 2
    break
fi

WGET_END=0
for ((BATTLE_NO=1;BATTLE_NO <= 2000;BATTLE_NO++)) {
    if [ $((WGET_END)) -eq  1 ]; then
        break
    fi

    for ((i=0;i < 3;i++)) { # 3回までリトライする
        if [ -s ./battle/${BATTLE_NO}_1.html ] || [ -s ./battle/${BATTLE_NO}_1.html.gz ]; then
            break
        fi

        wget -O ./battle/${BATTLE_NO}_1.html http://133.130.112.98/trialarea/battle/${BATTLE_NO}/1

        if grep -q "登録・ログイン" ./battle/${BATTLE_NO}_1.html; then
            WGET_END=1
            rm ./battle/${BATTLE_NO}_1.html
            break
        fi

        sleep 2

        if [ -s ./battle/${BATTLE_NO}_1.html ]; then
            break
        else
            sleep 10
        fi
    }
}

sleep 2
WGET_END=0
for ((BATTLE_NO=1;BATTLE_NO <= 2000;BATTLE_NO++)) {
    if [ $((WGET_END)) -eq  1 ]; then
        break
    fi

    for ((i=0;i < 3;i++)) { # 3回までリトライする
        if [ -s ./battle/${BATTLE_NO}_2.html ] || [ -s ./battle/${BATTLE_NO}_2.html.gz ]; then
            break
        fi

        wget -O ./battle/${BATTLE_NO}_2.html http://133.130.112.98/trialarea/battle/${BATTLE_NO}/2

        if grep -q "登録・ログイン" ./battle/${BATTLE_NO}_2.html; then
            WGET_END=1
            rm ./battle/${BATTLE_NO}_2.html
            break
        fi

        sleep 2

        if [ -s ./battle/${BATTLE_NO}_2.html ]; then
            break
        else
            sleep 10
        fi
    }
}

find . -type f -empty -delete
find . -type f -not -name "*.gz" -not -name "*.sh" | xargs gzip -9f

cd $CURENT  #元のディレクトリに戻る
