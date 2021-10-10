# 試行策謀データ小屋　解析プログラム
試行策謀データ小屋は[試行策謀](https://gameokiba.com/trialandscheme/)を解析して得られるデータを扱った情報サイトです。  
データ小屋の表示部分については[別リポジトリ](https://github.com/white-mns/trialarea_rails)を参照ください。

# サイト
実際に動いているサイトです。  
[試行策謀データ小屋](https://data.teiki.org/trialandscheme/)

# 動作環境
以下の環境での動作を確認しています  
  
OS:CentOS Linux release 8.2.2004  
DB:MySQL 8.0.21  
Perl:5.26.3  

## 必要なもの

bashが使えるLinux環境。（Windowsで処理を行う場合、execute.shの処理を手動で行ってください）  
perlが使える環境  
デフォルトで入ってないモジュールを使ってるので、

    cpan HTML::TreeBuilder

みたいにCPAN等を使ってDateTimeやHTML::TreeBuilderといった足りないモジュールをインストールしてください。

## 使い方
第1大会1回戦なら

    ./execute.sh 1 1 1

とします。  
1つ目の引数で結果のダウンロード処理を行うかを決定しています。  
既に結果をダウンロードしている場合、

    ./execute.sh 0 1 1

とすることでダウンロードは行わずローカルのみで処理を行います。

上手く動けばoutput内に中間ファイルcsvが生成され、指定したDBにデータが登録されます。  
`ConstData.pm`及び`ConstData_Upload.pm`を書き換えることで、処理を実行する項目を制限できます。

    ./_execute_all.sh 1 1 4

とすると、第1回大会の1回戦から4回戦までの確定結果を再解析します。  
この際、本家サイトから結果のダウンロードは行いません。

## DB設定
`source/DbSetting.pm`にサーバーの設定を記述します。  
DBのテーブルは[Railsアプリ側](https://github.com/white-mns/trialarea_rails)で`rake db:migrate`して作成しています。

## 中間ファイル
DBにアップロードしない場合、固有名詞を数字で置き換えている箇所があるため、csvファイルを読むのは難しいと思います。

    $$common_datas{ProperName}->GetOrAddId($$data[2])

のような`GetorAddId`、`GetId`関数で変換していますので、似たような箇所を全て

    $$data[2]

のように中身だけに書き換えることで元の文字列がcsvファイルに書き出され読みやすくなります。

## 絵文字
　データに絵文字を含むデータを扱う場合、mysqlであればmy.cnfに

    [libmysqlclient]
    default-character-set = utf8mb4

という二行を追加する必要があります。追加しない場合、絵文字を含むデータは正しくアップロードされません。（エラーは起きないので、絵文字を含まない文字列は正しい表示でアップロードされます）

## ライセンス
本ソフトウェアはMIT Licenceを採用しています。 ライセンスの詳細については`LICENSE`ファイルを参照してください。
