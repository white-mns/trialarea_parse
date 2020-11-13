#===================================================================
#        結果データ抽出スクリプト本体
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/ProperName.pm";
require "./source/Character.pm";
require "./source/SkillList.pm";
require "./source/MatchingList.pm";
require "./source/Battle.pm";
require "./source/UploadedCheck.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
use HTML::TreeBuilder;

# 変数の初期化    ---------------#
use FindBin qw($Bin);
use lib "$Bin";
use ConstData;        #定数呼び出し

# インスタンスの初期化    ---------------#

my $timeChecker = TimeChecker->new();


# 実行部    ---------------------------#

$timeChecker->CheckTime("Start  ");

&Main;

$timeChecker->CheckTime("End    ");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main{
    my $result_no = $ARGV[0];
    my $round_no  = $ARGV[1];

    if (!defined($result_no) || !defined($round_no) || $result_no !~ /^[0-9]+$/ || $round_no !~ /^[0-9]+$/) {
        print "Error:Unusual ResultNo or RoundNo\n";
        return;
    }

    my @objects;      #探索するデータ項目の登録
    my %common_datas;
    
    push(@objects, ProperName->new()); #固有名詞読み込み・保持
    push(@objects, SkillList->new());  # スキルリスト読み込み・保持
                                      {push(@objects, UploadedCheck->new());} # データ更新状況チェック用データ作成
    if (ConstData::EXE_BATTLE)        {push(@objects, Battle->new());}        # 戦闘読み込み
    if (ConstData::EXE_CHARA)         {push(@objects, Character->new());}     # キャラページ読み込み
    if (ConstData::EXE_MATCHING_LIST) {push(@objects, MatchingList->new());}  # 対戦組み合わせ読み込み

    &Init(\@objects, $result_no, $round_no, \%common_datas);
    &Execute(\@objects);
    &Output(\@objects);
}

#-----------------------------------#
#    解析実行
#------------------------------------
#    引数｜更新番号、再更新番号
#-----------------------------------#
sub Init{
    my ($objects, $result_no, $round_no, $common_datas)    = @_;
    
    foreach my $object( @$objects) {
        $object->Init($result_no, $round_no, $common_datas);
    }
    return;
}

#-----------------------------------#
#    解析実行
#------------------------------------
#    引数｜
#-----------------------------------#
sub Execute{
    my $objects    = shift;
    
    foreach my $object( @$objects) {
        $object->Execute();
    }
    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $objects    = shift;
    foreach my $object( @$objects) {
        $object->Output();
    }
    return;
}
