#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

#------------------------------------------------------------------
# 大会番号、ラウンド番号の定義確認、設定

DOMAIN="https://gameokiba.com/trialandscheme"
RESULT_NO=$1
RESULT_ADDR_NO=$1
ROUND_NO=$2

cd ./data/orig/

mkdir ./result
mkdir ./result_charalist
mkdir ./result_battlelist
mkdir ./battle
mkdir ./rule
mkdir ./rule/skill_list

wget --no-check-certificate -O ./result/${RESULT_ADDR_NO}.html ${DOMAIN}/result/${RESULT_ADDR_NO}
sleep 2
wget --no-check-certificate -O ./result_charalist/${RESULT_ADDR_NO}_${ROUND_NO}.html ${DOMAIN}/result_charalist/${RESULT_ADDR_NO}/${ROUND_NO}
sleep 2
wget --no-check-certificate -O ./result_battlelist/${RESULT_ADDR_NO}_${ROUND_NO}.html ${DOMAIN}/result_battlelist/${RESULT_ADDR_NO}/${ROUND_NO}
sleep 2

if [ ! -s ./rule/skill_list/${RESULT_ADDR_NO}.html ] && [ ! -s ./battle/${RESULT_ADDR_NO}.html.gz ]; then
    wget --no-check-certificate -O ./rule/skill_list/${RESULT_ADDR_NO}.html ${DOMAIN}/rule/skill_list
    sleep 2
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

        wget --no-check-certificate -O ./battle/${BATTLE_NO}_1.html ${DOMAIN}/battle/${BATTLE_NO}/1

        if grep -q "登録・ログイン" ./battle/${BATTLE_NO}_1.html; then
            WGET_END=1
            rm ./battle/${BATTLE_NO}_1.html
            break
        fi

        if grep -q "Not Found" ./battle/${BATTLE_NO}_1.html; then
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

        wget --no-check-certificate -O ./battle/${BATTLE_NO}_2.html ${DOMAIN}/battle/${BATTLE_NO}/2

        if grep -q "登録・ログイン" ./battle/${BATTLE_NO}_2.html; then
            WGET_END=1
            rm ./battle/${BATTLE_NO}_2.html
            break
        fi

        if grep -q "Not Found" ./battle/${BATTLE_NO}_2.html; then
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
