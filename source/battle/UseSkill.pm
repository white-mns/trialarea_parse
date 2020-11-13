#===================================================================
#        習得スキル取得パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package UseSkill;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{RoundNo}, $self->{CommonDatas}) = @_;

    #初期化
    $self->{Datas}{AllUseSkill} = StoreData->new();

    my $header_list = "";

    $header_list = [
                "result_no",
                "round_no",
                "battle_no",
                "skill_concatenate",
    ];

    $self->{Datas}{AllUseSkill}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{AllUseSkill}->SetOutputName( "./output/battle/all_use_skill_" . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $content = shift;
    my $battle_no     = shift;
    my $left_link_no  = shift;
    my $right_link_no = shift;

    $self->CrawlAction($content, $battle_no, $left_link_no, $right_link_no);

    return;
}

#-----------------------------------#
#    行動の走査
#------------------------------------
#    引数｜ファイル全文
#-----------------------------------#
sub CrawlAction{
    my $self  = shift;
    my $content  = shift;
    my $battle_no     = shift;
    my $left_link_no  = shift;
    my $right_link_no = shift;

    $self->{AllUseSkill} = {};

    my @actions = $content =~ /'msg':'.+?','wait':'\d+?','fontsize':'action'/g;

    foreach my $action (@actions) {
        $self->GetUseSkillData($action, $battle_no, $left_link_no, $right_link_no);
    }

    $self->AddAllUseSkill($battle_no);

    return;
}

#-----------------------------------#
#    スキル使用データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetUseSkillData{
    my $self  = shift;
    my $action  = shift;
    my $battle_no     = shift;
    my $left_link_no  = shift;
    my $right_link_no = shift;

    my ($link_no, $skill_name) = (0, "");

    if ($action =~ /msg':'(.+)の(.+?)！','wait/) {
        my $user_name = $1;
        
        if ($action =~ /msg':'(.+?)の(.+?)<span class/) {
            if ($action =~ /<span class="small">\((.+?)\)<\/span>/) { $skill_name = $1;}

        } elsif ($action =~ /msg':'(.+?)の(.+?)！','wait/) {
            $skill_name = $2;
            if ($skill_name eq "勝利") {return;}

        }
    }
    
    if (!$skill_name || $skill_name eq "") {return;}

    $self->{AllUseSkill}{$skill_name} = 1;

    return;
}

#-----------------------------------#
#    全使用スキルの記録
#------------------------------------
#    引数｜使用スキルのハッシュ配列
#-----------------------------------#
sub AddAllUseSkill{
    my $self  = shift;
    my $battle_no     = shift;

    my $all_use_skill = ",";

    foreach my $skill_name ( keys(%{$self->{AllUseSkill}}) ) {
        $all_use_skill .= $skill_name.",";
    }

    $self->{Datas}{AllUseSkill}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $battle_no, $all_use_skill)));

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
