object frmLUE: TfrmLUE
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Lookup Error Code'
  ClientHeight = 114
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 145
    Height = 50
    Caption = 'Error Code'
    TabOrder = 0
    object txtCode: TEdit
      Left = 16
      Top = 16
      Width = 121
      Height = 23
      AutoSelect = False
      MaxLength = 5
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 159
    Top = 8
    Width = 226
    Height = 81
    Caption = 'Error Message'
    TabOrder = 1
    object txtFmMsg: TMemo
      Left = 8
      Top = 16
      Width = 209
      Height = 57
      ReadOnly = True
      TabOrder = 0
    end
  end
  object btnLookup: TButton
    Left = 8
    Top = 64
    Width = 145
    Height = 25
    Caption = '[Lookup]'
    TabOrder = 2
    OnClick = btnLookupClick
  end
  object cbOnTop: TCheckBox
    Left = 8
    Top = 96
    Width = 73
    Height = 17
    Caption = 'On Top'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbOnTopClick
  end
end
