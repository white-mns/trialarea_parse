#!/bin/bash

CURRENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

RESULT_NO=$1
RESULT_ADDR_NO=$(($1 + 1))

for ((ROUND_NO=$2;ROUND_NO <= $3;ROUND_NO++)) {

    if [ -f ./data/orig/result_charalist/${RESULT_ADDR_NO}_${ROUND_NO}.html.gz ]; then
        echo "start $RESULT_NO, $ROUND_NO"
        ./execute.sh 0 $RESULT_NO $ROUND_NO
    fi
}

cd $CURRENT  #元のディレクトリに戻る
