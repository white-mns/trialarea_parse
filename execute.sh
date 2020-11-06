#!/bin/bash

CURRENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

#------------------------------------------------------------------
# 大会番号、ラウンド番号の定義確認、設定


# 大会番号の指定がない場合は処理しない
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Missing argument."
    exit
fi

EXECUTE_WGET=$1
RESULT_NO=$2
RESULT_ADDR_NO=$(($2 + 1))
ROUND_NO=$3

#------------------------------------------------------------------
# 結果に各個アクセスするシェルスクリプトを実行
if [ $EXECUTE_WGET -eq 1 ]; then
    ./_result_download.sh $RESULT_NO $ROUND_NO
fi
#------------------------------------------------------------------

# 解析処理の実行
perl ./GetData.pl $RESULT_NO $ROUND_NO $GENERATE_NO
perl ./UploadParent.pl $RESULT_NO $ROUND_NO $GENERATE_NO


cd $CURRENT  #元のディレクトリに戻る
