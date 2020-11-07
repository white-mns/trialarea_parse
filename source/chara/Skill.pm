#===================================================================
#        PC名、愛称取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
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
package Skill;

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
    $self->{Datas}{Data}             = StoreData->new();
    $self->{Datas}{SkillConcatenate} = StoreData->new();

    my $header_list = "";
   
    $header_list = [
                "result_no",
                "round_no",
                "link_no",
                "skill_id",
    ];

    $self->{Datas}{Data}->Init($header_list);

    $header_list = [
                "result_no",
                "round_no",
                "link_no",
                "skill_concatenate",
    ];

    $self->{Datas}{SkillConcatenate}->Init($header_list);

    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName            ( "./output/chara/skill_"             . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
    $self->{Datas}{SkillConcatenate}->SetOutputName( "./output/chara/skill_concatenate_" . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $a_nodes = shift;

    $self->CrawlLinkNode($a_nodes);

    return;
}

#-----------------------------------#
#    リンクノードの走査
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub CrawlLinkNode{
    my $self  = shift;
    my $a_nodes  = shift;

    foreach my $a_node ( @$a_nodes) {
        if ($a_node->attr("name") && $a_node->attr("name") =~ /^[0-9]+$/) {
            $self->GetSkillData($a_node);
        }
    }

    return;
}

#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $a_node  = shift;
    my $link_no = 0;

    my $right_node = $a_node->right;

    $link_no = $a_node->attr("name");
    
    my $span_tooltip_nodes = &GetNode::GetNode_Tag_Attr("span", "data-toggle", "tooltip", \$right_node);
    my $skill_concatenate = ",";

    foreach my $span_tooltip_node (@$span_tooltip_nodes) {
        my $name = $span_tooltip_node->as_text;
        my $skill_id = $self->{CommonDatas}{SkillList}->GetOrAddId(0, [$name, $self->{ResultNo}, -1, -1, "", 0, 0, 0, 0, 0, 0, 0, 0]);

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $link_no, $skill_id)));

        $skill_concatenate .= $name.",";
    }

    $self->{Datas}{SkillConcatenate}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $link_no, $skill_concatenate)));

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
