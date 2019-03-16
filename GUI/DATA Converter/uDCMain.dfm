object frmDC: TfrmDC
  Left = 0
  Top = 0
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'DATA Converter'
  ClientHeight = 437
  ClientWidth = 798
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
    Top = 3
    Width = 782
    Height = 353
    Caption = '[Data (The Data Hex Byte copy from: OllyDbg\Binary\Binary Copy)]'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    object mmData: TMemo
      Left = 8
      Top = 24
      Width = 761
      Height = 321
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 362
    Width = 177
    Height = 49
    Caption = '[Convert to array of]'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    object Lang: TComboBox
      Left = 8
      Top = 16
      Width = 153
      Height = 22
      Style = csOwnerDrawFixed
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 0
      OnChange = LangChange
      Items.Strings = (
        'Pascal/Delphi'
        'C/C++'
        'C#/Java'
        'Assembly'
        'Lua'
        'Python/Ruby')
    end
  end
  object GroupBox3: TGroupBox
    Left = 191
    Top = 362
    Width = 599
    Height = 49
    TabOrder = 2
    object btnCopy: TButton
      Left = 143
      Top = 16
      Width = 62
      Height = 25
      Caption = '[Copy]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnCopyClick
    end
    object btnPaste: TButton
      Left = 79
      Top = 16
      Width = 58
      Height = 25
      Caption = '[Paste]'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnPasteClick
    end
    object btnClear: TButton
      Left = 11
      Top = 16
      Width = 62
      Height = 25
      Caption = '[Clear]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnConverter: TButton
      Left = 211
      Top = 16
      Width = 374
      Height = 25
      Caption = '[Convert Data To Array Of Pascal/Delphi]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnConverterClick
    end
  end
  object cbOnTop: TCheckBox
    Left = 8
    Top = 417
    Width = 97
    Height = 17
    Caption = 'Stay On Top'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbOnTopClick
  end
  object XPManifest1: TXPManifest
    Left = 136
    Top = 416
  end
end
