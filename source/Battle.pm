#===================================================================
#        戦闘解析パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/battle/UseSkill.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

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
    $self->{ResultAddrNo} = $self->{ResultNo};
    
    #他パッケージへの引き渡し用
    $self->{CommonDatas}{Battle} = $self;

    #インスタンス作成
    if (ConstData::EXE_BATTLE_USE_SKILL)  { $self->{DataHandlers}{UseSkill}  = UseSkill->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{RoundNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self          = shift;
    my $battle_no     = shift;
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    if (!$battle_no) {return;}

    my $directory = './data/orig/battle/';
    
    $self->ParsePage($directory . $battle_no . "_2" . ".html", $battle_no, $left_pc_name_data, $right_pc_name_data);
    
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
    my $battle_no     = shift;
    my $left_pc_name_data  = shift;
    my $right_pc_name_data = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::GzipRead($file_name);

    if (!$content) { return;}

    # データリスト取得
    if (exists($self->{DataHandlers}{UseSkill})) {$self->{DataHandlers}{UseSkill}->GetData($content, $battle_no, $left_pc_name_data, $right_pc_name_data)};
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
