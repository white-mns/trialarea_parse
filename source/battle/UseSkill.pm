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
    $self->{Datas}{AllUseSkill}   = StoreData->new();
    $self->{Datas}{CharaUseSkill} = StoreData->new();

    my $header_list = "";

    $header_list = [
                "result_no",
                "round_no",
                "battle_no",
                "skill_concatenate",
    ];

    $self->{Datas}{AllUseSkill}->Init($header_list);

    $header_list = [
                "result_no",
                "round_no",
                "battle_no",
                "link_no",
                "skill_concatenate",
    ];

    $self->{Datas}{CharaUseSkill}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{AllUseSkill}->  SetOutputName( "./output/battle/all_use_skill_"   . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
    $self->{Datas}{CharaUseSkill}->SetOutputName( "./output/battle/chara_use_skill_" . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
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
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    $self->CrawlAction($content, $battle_no, $left_pc_name_data, $right_pc_name_data);

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
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    $self->{AllUseSkill}   = {};
    $self->{LeftUseSkill}  = {};
    $self->{RightUseSkill} = {};

    my @actions = $content =~ /'msg':'.+?','wait':'\d+?','fontsize':'action'/g;

    foreach my $action (@actions) {
        $self->GetUseSkillData($action, $battle_no, $left_pc_name_data, $right_pc_name_data);
    }

    $self->AddAllUseSkill($battle_no);
    $self->AddCharaUseSkill($battle_no, $$left_pc_name_data[0],  $self->{LeftUseSkill});
    $self->AddCharaUseSkill($battle_no, $$right_pc_name_data[0], $self->{RightUseSkill});

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
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    my ($link_no, $user_name, $skill_name) = (0, "", "");

    if ($action =~ /msg':'(.+)の(.+?)！','wait/) {
        $user_name = $1;
        
        if ($action =~ /msg':'(.+?)の(.+?)<span class/) {
            if ($action =~ /<span class="small">\((.+?)\)<\/span>/) { $skill_name = $1;}

        } elsif ($action =~ /msg':'(.+?)の(.+?)！','wait/) {
            $skill_name = $2;
            if ($skill_name eq "勝利") {return;}

        }
    }
    
    if (!$skill_name || $skill_name eq "") {return;}

    $self->{AllUseSkill}{$skill_name} = 1;

    if ($user_name eq $$left_pc_name_data[1]) {
        $self->{LeftUseSkill}{$skill_name} = 1;
    }

    if ($user_name eq $$right_pc_name_data[1]) {
        $self->{RightUseSkill}{$skill_name} = 1;
    }

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
#    キャラクター使用スキルの記録
#------------------------------------
#    引数｜キャラクター番号
#    　　　使用スキルのハッシュ配列
#-----------------------------------#
sub AddCharaUseSkill{
    my $self  = shift;
    my $battle_no   = shift;
    my $link_no     = shift;
    my $use_skills  = shift;

    my $chara_use_skill = ",";

    foreach my $skill_name ( keys(%$use_skills) ) {
        $chara_use_skill .= $skill_name.",";
    }

    $self->{Datas}{CharaUseSkill}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $battle_no, $link_no, $chara_use_skill)));

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
