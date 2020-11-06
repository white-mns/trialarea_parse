#===================================================================
#    データベースへのアップロード
#-------------------------------------------------------------------
#        (C) 2018 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/Upload.pm";
require "./source/lib/time.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
require LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

# 変数の初期化    ---------------#
use FindBin qw($Bin);
use lib "$Bin";
use ConstData_Upload;        #定数呼び出し

# インスタンスの初期化    ---------------#

my $timeChecker = TimeChecker->new();

# 実行部    ---------------------------#
$timeChecker->CheckTime("start  \t");

&Main;

$timeChecker->CheckTime("end    \t");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main {
    my $result_no = $ARGV[0];
    my $round_no = $ARGV[1];
    my $upload = Upload->new();

    if (!defined($result_no) || !defined($round_no) || $result_no !~ /^[0-9]+$/ || $round_no !~ /^[0-9]+$/) {
        print "Error:Unusual ResultNo or RoundNo\n";
        return;
    }

    $upload->DBConnect();
    
    $upload->DeleteSameResult("uploaded_checks", $result_no, $round_no);

    if (ConstData::EXE_DATA) {
        &UploadData($upload, ConstData::EXE_DATA_PROPER_NAME, "proper_names", "./output/data/proper_name.csv");
    }
    if (ConstData::EXE_CHARA) {
        &UploadResult($upload, $result_no, $round_no, ConstData::EXE_CHARA_NAME, "names", "./output/chara/name_");
    }
        &UploadResult($upload, $result_no, $round_no, 1,                      "uploaded_checks",     "./output/etc/uploaded_check_");
    print "result_no:$result_no,round_no:$round_no\n";
    return;
}

#-----------------------------------#
#       結果番号に依らないデータをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadData {
    my ($upload, $is_upload, $table_name, $file_name) = @_;

    if ($is_upload) {
        $upload->DeleteAll($table_name);
        $upload->Upload($file_name, $table_name);
    }
}

#-----------------------------------#
#       更新結果データをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　更新番号
#    　　　再更新番号
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadResult {
    my ($upload, $result_no, $round_no, $is_upload, $table_name, $file_name) = @_;

    if($is_upload) {
        $upload->DeleteSameRound($table_name, $result_no, $round_no);
        $upload->Upload($file_name . $result_no . "_" . $round_no . ".csv", $table_name);
    }
}
