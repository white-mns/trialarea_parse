#===================================================================
#        PC名、愛称取得パッケージ
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
package Name;

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

    $self->{CommonDatas}{NickName} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "round_no",
                "player_id",
                "link_no",
                "name",
                "player",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/name_" . $self->{ResultNo} . "_" . $self->{RoundNo} . ".csv" );
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
            $self->GetNameData($a_node);
        }
    }

    return;
}

#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $a_node  = shift;
    my ($player_id, $link_no, $name, $player) = (0, 0, "", "");

    my @right_children = $a_node->right->content_list;

    $link_no = $a_node->attr("name");
    $name =  $right_children[1]->as_text;
    $player =  $right_children[2]->as_text;
    $player =~ s/プレイヤー：//g;

    if ($player =~ / \[(\d+)\]/) {
        $player_id = $1;
        $player =~ s/ \[\d+\]//g;
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{RoundNo}, $player_id, $link_no, $name, $player)));


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
