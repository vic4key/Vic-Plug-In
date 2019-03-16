object frmTimerConfig: TfrmTimerConfig
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Timer Config'
  ClientHeight = 67
  ClientWidth = 259
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 63
    Height = 15
    Caption = 'Time (ms)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object LbTime: TLabel
    Left = 98
    Top = 46
    Width = 28
    Height = 15
    Caption = 'Time'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 46
    Width = 84
    Height = 15
    Caption = 'Time (Clock)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object TxtTimer: TEdit
    Left = 77
    Top = 8
    Width = 53
    Height = 23
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 6
    ParentFont = False
    TabOrder = 0
    Text = '999999'
    OnChange = TxtTimerChange
  end
  object Button1: TButton
    Left = 136
    Top = 8
    Width = 114
    Height = 21
    Caption = 'Apply && Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
  end
end
