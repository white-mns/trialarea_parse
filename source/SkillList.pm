#===================================================================
#        スキルリスト解析パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/data/StoreProperData.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package SkillList;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init() {
    my $self = shift;
    ($self->{ResultNo}, $self->{RoundNo}, $self->{CommonDatas}) = @_;
    $self->{ResultAddrNo} = $self->{ResultNo} + 1;

    #インスタンス作成
    $self->{DataHandlers}{SkillList} = StoreProperData->new();

    #他パッケージへの引き渡し用インスタンス
    $self->{CommonDatas}{SkillList} = $self->{DataHandlers}{SkillList};

    my $header_list = "";
    my $output_file = "";

    $header_list = [
                "skill_id",
                "name",
                "result_no",
                "skill_type",
                "ap",
                "text",
                "is_physics",
                "is_fire",
                "is_aqua",
                "is_wind",
                "is_quake",
                "is_light",
                "is_dark",
                "is_poison",
    ];
    $output_file = "./output/data/". "skill_list_" . $self->{ResultNo} . ".csv";
    $self->{DataHandlers}{SkillList}->Init($header_list, $output_file, [" ", 0, -1, -1, " ", 0, 0, 0, 0, 0, 0, 0, 0]);
    $self->{DataHandlers}{SkillList}->Init($header_list, $output_file," ");
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read skill files...\n";

    my $directory = './data/orig/rule/skill_list/';
    
    $self->ParsePage($directory . $self->{ResultAddrNo} . ".html");
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::GzipRead($file_name);

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $div_ability_nodes = &GetNode::GetNode_Tag_Attr("div", "class", "ability",     \$tree);
    my $div_awake_nodes   = &GetNode::GetNode_Tag_Attr("div", "class", "awake_skill", \$tree);
    my $div_skill_nodes   = &GetNode::GetNode_Tag_Attr("div", "class", "skill",       \$tree);

    # データリスト取得
    $self->CrawlSkillNode($div_ability_nodes, 1);
    $self->CrawlSkillNode($div_awake_nodes,   2);
    $self->CrawlSkillNode($div_skill_nodes,   0);

    $tree = $tree->delete;
}

#-----------------------------------#
#    スキルデータノードの走査
#------------------------------------
#    引数｜スキルデータノード
#-----------------------------------#
sub CrawlSkillNode{
    my $self  = shift;
    my $div_nodes  = shift;
    my $skill_type  = shift;

    foreach my $div_node ( @$div_nodes) {
        $self->GetSkillData($div_node, $skill_type);
    }

    return;
}

#-----------------------------------#
#    スキルデータ取得
#------------------------------------
#    引数｜スキルデータノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $div_node  = shift;
    my $skill_type  = shift;
    my ($name, $ap, $text, $is_physics, $is_fire, $is_aqua, $is_wind, $is_quake, $is_light, $is_dark, $is_poison) = ("", -1, "", 0, 0, 0, 0, 0, 0, 0, 0);
    my @node_children = $div_node->content_list;

    $name = $div_node->attr("data-name");

    my $ap_node = $node_children[1];
    my $text_node = (scalar(@node_children) > 3) ? $node_children[2] : $node_children[1];

    if ($ap_node->as_text =~ /^AP(\d+)/) {
        $ap = $1;
    }

    if ($text_node =~ /HASH/) {
        $text = $text_node->as_text;
    }

    my @elements = (["物理", \$is_physics], ["火", \$is_fire], ["水", \$is_aqua], ["風", \$is_wind], ["地", \$is_quake], ["光", \$is_light], ["闇", \$is_dark]);

    foreach my $element (@elements) {
        if ($text =~ /の$$element[0]攻撃を/) {
            ${$$element[1]} = 1;
        }
        if ($text =~ /の物理・$$element[0]攻撃を/) {
            $is_physics = 1;
            ${$$element[1]} = 1;
        }
    }

    if ($text =~ /相手の\[毒\]Lv\+/) {
        $is_poison = 1;
    }
    if ($name eq "ダーティクロー") {
        $is_poison = 1;
    }

    $self->{CommonDatas}{SkillList}->GetOrAddId(1, [$name, $self->{ResultNo}, $skill_type, $ap, $text, $is_physics, $is_fire, $is_aqua, $is_wind, $is_quake, $is_light, $is_dark, $is_poison]);

    return;
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
