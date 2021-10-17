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
                "skill_concatenate_ex",
                "seclusion_skill_id",
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

    my @actions = $content =~ /'msg':'.+?','fontsize':'action'/g;

    foreach my $action (@actions) {
        if ($action =~ /'msg':'(.+?)'/) {
            my $msg = $1;
            $self->GetUseSkillData($msg, $battle_no, $left_pc_name_data, $right_pc_name_data);
        }
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
    my $msg  = shift;
    my $battle_no     = shift;
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    my ($link_no, $skill_name) = (0, "");

    if ($msg =~ /.+の(.+?)！$/) {
        
        if ($msg =~ /.+?の(.+?)<span class/) {
            if ($msg =~ /<span class="small">\((.+?)\)<\/span>/) { $skill_name = $1;}

        } elsif ($msg =~ /.+?の(.+?)！$/) {
            $skill_name = $1;

            my @no_splits = split(/の/, $msg);
            if (scalar(@no_splits) > 2) {
                my $splits_length = scalar(@no_splits);
                $skill_name = $no_splits[$splits_length - 1];
                $skill_name =~ s/！//;
            }

            if ($skill_name eq "勝利") {return;}

        }
    }
    
    if (!$skill_name || $skill_name eq "") {return;}

    $self->{AllUseSkill}{$skill_name} = 1;

    if ($msg =~ /$$left_pc_name_data[1]/) {
        if (exists($self->{LeftUseSkill}{$skill_name})) {
            $self->{LeftUseSkill}{$skill_name} += 1;
        } else {
            $self->{LeftUseSkill}{$skill_name} = 1;
        }
    }

    if ($msg =~ /$$right_pc_name_data[1]/) {
        if (exists($self->{RightUseSkill}{$skill_name})) {
            $self->{RightUseSkill}{$skill_name} += 1;
        } else {
            $self->{RightUseSkill}{$skill_name} = 1;
        }
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

    foreach my $skill_name (sort{$a cmp $b}(keys(%{$self->{AllUseSkill}}))) {
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
    my $chara_use_skill_ex = ",";
    my $seclusion_skill_id = 0;

    foreach my $skill_name (sort{$a cmp $b}(keys(%$use_skills))) {
        $chara_use_skill .= $skill_name.",";
        if (!exists($self->{CommonDatas}{isLearnedSkill}{$link_no}{$skill_name}) && !exists($self->{CommonDatas}{isAwakeSkill}{$skill_name})) {
            $chara_use_skill_ex .=  "!"; # 習得スキルにないものを使ったら非公開フラグ追加
            $seclusion_skill_id = $self->{CommonDatas}{SkillList}->GetOrAddId(0, [$skill_name, $self->{ResultNo}, -1, -1, "", 0, 0, 0, 0, 0, 0, 0, 0]);
        }
        $chara_use_skill_ex .= $skill_name . " (" . $$use_skills{$skill_name} . "回),";
    }

    $self->{Datas}{CharaUseSkill}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $battle_no, $link_no, $chara_use_skill, $chara_use_skill_ex, $seclusion_skill_id)));

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
