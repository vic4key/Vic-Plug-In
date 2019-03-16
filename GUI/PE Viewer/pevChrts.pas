unit pevChrts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCrtics = class(TForm)
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    Button1: TButton;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Crtics: TCrtics;

implementation

uses pevMain;

{$R *.dfm}

procedure TCrtics.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
  begin
    pevMain.PE_Viewer.Show;
  end;
end;

procedure TCrtics.FormCreate(Sender: TObject);
begin
  if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
  begin
    Self.FormStyle:= fsStayOnTop;
  end
  else
  begin
    Self.FormStyle:= fsNormal;
  end;
  
  SetWindowLongA(Button1.Handle,GWL_STYLE,(GetWindowLongA(Button1.Handle,GWL_STYLE) or BS_FLAT));
    CheckBox1.Hint:='特征值：'+ CheckBox1.Caption+ ' = 0x0001'+#13+#13+
                    '仅映象, Windows CE, Windows NT 及以上. 指明文件不包括基本' +#13+
                    '的重定位和因此必须载入它到它的首选基地址. 如果该基地址不' +#13+
                    '可用, 载入器报告一个错误. 运行在 MS-DOS (Win32s? 的上的操' +#13+
                    '作系统通常不能使用预定义基地址并因此不能运行这些映象.' +#13+
                    '但是, 从 4.0 版开始, Windows 将使用一个首选基地址. 默认的连' +#13+
                    '使用一个首选基地址. 默认的连接器行为是从 EXE 中跳过基本重定位.';

    CheckBox2.Hint:='特征值：'+ CheckBox2.Caption+ ' = 0x0002'+#13+#13+
                    '仅映象. 指明映象文件是可用的并可以运行. 如果该标记未设置,' +#13+
                    '通常表示一个连接器错误.';
    CheckBox3.Hint:='特征值：'+ CheckBox3.Caption+ ' = 0x0004'+#13+#13+
                    '已移去的 COFF 行数.';   
    CheckBox4.Hint:='特征值：'+ CheckBox4.Caption+ ' = 0x0008'+#13+#13+
                    '已移去的用于本地符号的 COFF 符号表入口.';
    CheckBox5.Hint:='特征值：'+ CheckBox5.Caption+ ' = 0x0010'+#13+#13+
                    '侵略地修整工作设置.';
    CheckBox6.Hint:='特征值：'+ CheckBox6.Caption+ ' = 0x0080'+#13+#13+
                    'Little endian: 在内存中 LSB 领先于 MSB.';
    CheckBox7.Hint:='特征值：'+ CheckBox7.Caption+ ' = 0x0100'+#13+#13+
                    '机器基于 32-位-字 体系';
    CheckBox8.Hint:='特征值：'+ CheckBox8.Caption+ ' = 0x0200'+#13+#13+
                    '从映象文件中移去调试信息.';
    CheckBox9.Hint:='特征值：'+ CheckBox9.Caption+ ' = 0x0400'+#13+#13+
                    '如果映象在可移动媒体上, 复制并从交换文件中运行.';
    CheckBox10.Hint:='特征值：'+ CheckBox10.Caption+ ' = 0x0800'+#13+#13+
                     '置1表示程序不能在网上运行。在这种情况下 ,OS 必须把文件拷贝到交换文件中执行。';
    CheckBox11.Hint:='特征值：'+ CheckBox11.Caption+ ' = 0x1000'+#13+#13+
                    '映象文件是一个系统文件, 不是一个用户程序.';
    CheckBox12.Hint:='特征值：'+ CheckBox12.Caption+ ' = 0x2000'+#13+#13+
                    '映象文件是一个动态连接库 (DLL). 虽然它不能直接运行, 但还是认为它是一个可执行文件.';
    CheckBox13.Hint:='特征值：'+ CheckBox2.Caption+ ' = 0x4000'+#13+#13+
                    '文件只能运行在 UP 机器上.';
    CheckBox14.Hint:='特征值：'+ CheckBox2.Caption+ ' = 0x8000'+#13+#13+
                    'Big endian: 在内存中 MSB 领先于  LSB.';  
end;

procedure TCrtics.FormShow(Sender: TObject);
begin
  if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
  begin
    pevMain.PE_Viewer.Hide;
  end;
end;

procedure TCrtics.Button1Click(Sender: TObject);
begin
   PE_Viewer.CheckCharactistics;
end;

end.
 