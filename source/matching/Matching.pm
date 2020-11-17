#===================================================================
#        対戦組み合わせ取得パッケージ
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
package Matching;

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

    $self->{CommonDatas}{NickMatching} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "round_no",
                "battle_no",
                "left_link_no",
                "right_link_no",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/matching/matching_" . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $div_nodes = shift;

    $self->CrawlMatchingNode($div_nodes);

    return;
}

#-----------------------------------#
#    対戦組み合わせノードの走査
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub CrawlMatchingNode{
    my $self  = shift;
    my $div_nodes  = shift;
    my ($battle_no, $left_link_no, $right_link_no) = (0,0,0);
    my ($left_pc_name, $right_pc_name) = ("","");

    foreach my $div_node ( @$div_nodes) {
        my $a_nodes = &GetNode::GetNode_Tag("a", \$div_node);

        if (!scalar(@$a_nodes)) {next;}

        if ($$a_nodes[0] && $$a_nodes[0]->attr("href") && $$a_nodes[0]->attr("href") =~ /\#(\d+)/) {
            $left_link_no = $1;
            $left_pc_name = $$a_nodes[0]->as_text;
        }

        if ($$a_nodes[1] && $$a_nodes[1]->attr("href") && $$a_nodes[1]->attr("href") =~ /\#(\d+)/) {
            $right_link_no = $1;
            $right_pc_name = $$a_nodes[1]->as_text;
        }
        
        if ($$a_nodes[2] && $$a_nodes[2]->attr("href") && $$a_nodes[2]->attr("href") =~ /battle\/(\d+)/) { $battle_no = $1;}

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $battle_no, $left_link_no, $right_link_no)));
        
        if ($battle_no > 0 && $self->{CommonDatas}{Battle}) {
            print $battle_no."\n";
            $self->{CommonDatas}{Battle}->Execute($battle_no, [$left_link_no, $left_pc_name], [$right_link_no, $right_pc_name]);
        }
    }

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
