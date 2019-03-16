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
    CheckBox1.Hint:='����ֵ��'+ CheckBox1.Caption+ ' = 0x0001'+#13+#13+
                    '��ӳ��, Windows CE, Windows NT ������. ָ���ļ�����������' +#13+
                    '���ض�λ����˱�����������������ѡ����ַ. ����û���ַ��' +#13+
                    '����, ����������һ������. ������ MS-DOS (Win32s? ���ϵĲ�' +#13+
                    '��ϵͳͨ������ʹ��Ԥ�������ַ����˲���������Щӳ��.' +#13+
                    '����, �� 4.0 �濪ʼ, Windows ��ʹ��һ����ѡ����ַ. Ĭ�ϵ���' +#13+
                    'ʹ��һ����ѡ����ַ. Ĭ�ϵ���������Ϊ�Ǵ� EXE �����������ض�λ.';

    CheckBox2.Hint:='����ֵ��'+ CheckBox2.Caption+ ' = 0x0002'+#13+#13+
                    '��ӳ��. ָ��ӳ���ļ��ǿ��õĲ���������. ����ñ��δ����,' +#13+
                    'ͨ����ʾһ������������.';
    CheckBox3.Hint:='����ֵ��'+ CheckBox3.Caption+ ' = 0x0004'+#13+#13+
                    '����ȥ�� COFF ����.';   
    CheckBox4.Hint:='����ֵ��'+ CheckBox4.Caption+ ' = 0x0008'+#13+#13+
                    '����ȥ�����ڱ��ط��ŵ� COFF ���ű����.';
    CheckBox5.Hint:='����ֵ��'+ CheckBox5.Caption+ ' = 0x0010'+#13+#13+
                    '���Ե�������������.';
    CheckBox6.Hint:='����ֵ��'+ CheckBox6.Caption+ ' = 0x0080'+#13+#13+
                    'Little endian: ���ڴ��� LSB ������ MSB.';
    CheckBox7.Hint:='����ֵ��'+ CheckBox7.Caption+ ' = 0x0100'+#13+#13+
                    '�������� 32-λ-�� ��ϵ';
    CheckBox8.Hint:='����ֵ��'+ CheckBox8.Caption+ ' = 0x0200'+#13+#13+
                    '��ӳ���ļ�����ȥ������Ϣ.';
    CheckBox9.Hint:='����ֵ��'+ CheckBox9.Caption+ ' = 0x0400'+#13+#13+
                    '���ӳ���ڿ��ƶ�ý����, ���Ʋ��ӽ����ļ�������.';
    CheckBox10.Hint:='����ֵ��'+ CheckBox10.Caption+ ' = 0x0800'+#13+#13+
                     '��1��ʾ���������������С������������ ,OS ������ļ������������ļ���ִ�С�';
    CheckBox11.Hint:='����ֵ��'+ CheckBox11.Caption+ ' = 0x1000'+#13+#13+
                    'ӳ���ļ���һ��ϵͳ�ļ�, ����һ���û�����.';
    CheckBox12.Hint:='����ֵ��'+ CheckBox12.Caption+ ' = 0x2000'+#13+#13+
                    'ӳ���ļ���һ����̬���ӿ� (DLL). ��Ȼ������ֱ������, ��������Ϊ����һ����ִ���ļ�.';
    CheckBox13.Hint:='����ֵ��'+ CheckBox2.Caption+ ' = 0x4000'+#13+#13+
                    '�ļ�ֻ�������� UP ������.';
    CheckBox14.Hint:='����ֵ��'+ CheckBox2.Caption+ ' = 0x8000'+#13+#13+
                    'Big endian: ���ڴ��� MSB ������  LSB.';  
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
 