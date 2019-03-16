object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Transparency'
  ClientHeight = 96
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 0
    Width = 88
    Height = 13
    Caption = 'Transparent Value'
  end
  object lbValue: TLabel
    Left = 102
    Top = 0
    Width = 17
    Height = 13
    Caption = '0%'
  end
  object tbTran: TTrackBar
    Left = 8
    Top = 19
    Width = 328
    Height = 45
    Max = 51
    Min = 8
    Position = 9
    ShowSelRange = False
    TabOrder = 0
    OnChange = tbTranChange
  end
  object Button1: TButton
    Left = 8
    Top = 69
    Width = 328
    Height = 19
    Caption = '[OK]'
    TabOrder = 1
    OnClick = Button1Click
  end
end
