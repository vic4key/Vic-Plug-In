object frmTranOD: TfrmTranOD
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Transparency'
  ClientHeight = 116
  ClientWidth = 344
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 0
    Width = 119
    Height = 15
    Caption = 'Transparent Value'
  end
  object lbValue: TLabel
    Left = 133
    Top = 0
    Width = 14
    Height = 15
    Caption = '0%'
  end
  object tbTran: TTrackBar
    Left = 8
    Top = 19
    Width = 328
    Height = 45
    Max = 51
    Min = 8
    Position = 47
    ShowSelRange = False
    TabOrder = 0
    OnChange = tbTranChange
  end
  object Button1: TButton
    Left = 8
    Top = 62
    Width = 328
    Height = 27
    Caption = '[OK]'
    TabOrder = 1
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 95
    Width = 119
    Height = 17
    Caption = 'Always On Top'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBox1Click
  end
end
