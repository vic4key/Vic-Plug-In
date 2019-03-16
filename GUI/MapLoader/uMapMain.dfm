object frmMapLoader: TfrmMapLoader
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Map File Importer'
  ClientHeight = 234
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 214
    Width = 42
    Height = 15
    Caption = 'Status'
  end
  object lbStatus: TLabel
    Left = 56
    Top = 214
    Width = 49
    Height = 15
    Caption = 'Nothing'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 57
    Caption = ' [Loaded Modules List] '
    TabOrder = 0
    object cbLoadedModules: TComboBox
      Left = 16
      Top = 24
      Width = 264
      Height = 23
      Style = csDropDownList
      ItemHeight = 15
      TabOrder = 0
      OnSelect = cbLoadedModulesSelect
    end
  end
  object btnLoad: TButton
    Left = 8
    Top = 183
    Width = 75
    Height = 25
    Caption = '[Import]'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 71
    Width = 289
    Height = 50
    Caption = ' [Map Type] '
    TabOrder = 2
    object rbLabel: TRadioButton
      Left = 16
      Top = 24
      Width = 59
      Height = 17
      Caption = 'Label'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbComment: TRadioButton
      Left = 200
      Top = 24
      Width = 80
      Height = 17
      BiDiMode = bdRightToLeft
      Caption = 'Comment'
      ParentBiDiMode = False
      TabOrder = 1
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 127
    Width = 289
    Height = 50
    Caption = ' [Map file path] '
    TabOrder = 3
    object txtMapFile: TEdit
      Left = 16
      Top = 20
      Width = 217
      Height = 23
      AutoSelect = False
      ReadOnly = True
      TabOrder = 0
    end
    object btnOpenMapFile: TButton
      Left = 239
      Top = 20
      Width = 41
      Height = 21
      Caption = 'Open'
      Enabled = False
      TabOrder = 1
      OnClick = btnOpenMapFileClick
    end
  end
  object cbOnTop: TCheckBox
    Left = 184
    Top = 187
    Width = 113
    Height = 17
    Caption = 'Alway On Top'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = cbOnTopClick
  end
  object OpenDialog1: TOpenDialog
    OnClose = OpenDialog1Close
    OnShow = OpenDialog1Show
    DefaultExt = '*.map'
    Filter = 'Map file|*.map'
    Title = 'Open map file'
    Left = 240
    Top = 240
  end
end
