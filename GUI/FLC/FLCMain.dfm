object frmFLC: TfrmFLC
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'File Location Converter'
  ClientHeight = 263
  ClientWidth = 688
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
    Top = 135
    Width = 193
    Height = 120
    Caption = '[Address converter]'
    TabOrder = 0
    object rdOffset: TRadioButton
      Left = 16
      Top = 24
      Width = 57
      Height = 17
      Caption = 'Offset'
      TabOrder = 0
      OnClick = rdOffsetClick
    end
    object rdRVA: TRadioButton
      Left = 16
      Top = 55
      Width = 57
      Height = 17
      Caption = 'RVA'
      TabOrder = 1
      OnClick = rdRVAClick
    end
    object rdVA: TRadioButton
      Left = 16
      Top = 88
      Width = 57
      Height = 17
      Caption = 'VA'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = rdVAClick
    end
    object txtOffset: TEdit
      Left = 115
      Top = 20
      Width = 69
      Height = 23
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      ReadOnly = True
      TabOrder = 3
      OnChange = txtOffsetChange
      OnKeyPress = txtOffsetKeyPress
    end
    object txtRVA: TEdit
      Left = 115
      Top = 53
      Width = 69
      Height = 23
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      ReadOnly = True
      TabOrder = 4
      OnChange = txtRVAChange
      OnKeyPress = txtRVAKeyPress
    end
    object txtVA: TEdit
      Left = 115
      Top = 86
      Width = 69
      Height = 23
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      TabOrder = 5
      OnChange = txtVAChange
      OnKeyPress = txtVAKeyPress
    end
  end
  object GroupBox2: TGroupBox
    Left = 207
    Top = 8
    Width = 474
    Height = 216
    Caption = '[Sections Infomation]'
    TabOrder = 1
    object lSInfo: TListView
      Left = 8
      Top = 16
      Width = 457
      Height = 185
      Align = alCustom
      Columns = <
        item
          Caption = 'Name'
        end
        item
          Caption = 'VA'
          Width = 83
        end
        item
          Caption = 'VSize'
          Width = 82
        end
        item
          Caption = 'Offset'
          Width = 79
        end
        item
          Caption = 'RSize'
          Width = 73
        end
        item
          Caption = 'Flags'
          Width = 80
        end>
      GridLines = True
      HotTrack = True
      ReadOnly = True
      RowSelect = True
      ShowWorkAreas = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object btnOpen: TButton
    Left = 447
    Top = 288
    Width = 65
    Height = 26
    Caption = '[Open]'
    Enabled = False
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object cbOnTop: TCheckBox
    Left = 557
    Top = 238
    Width = 100
    Height = 17
    Caption = 'Stay On Top'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbOnTopClick
  end
  object btnGoto: TButton
    Left = 207
    Top = 229
    Width = 74
    Height = 26
    Caption = 'Goto'
    TabOrder = 4
    OnClick = btnGotoClick
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 8
    Width = 193
    Height = 49
    Caption = '[Modules]'
    TabOrder = 5
    object cbLoadedModules: TComboBox
      Left = 8
      Top = 16
      Width = 177
      Height = 23
      Style = csDropDownList
      ItemHeight = 15
      TabOrder = 0
      OnSelect = cbLoadedModulesSelect
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 63
    Width = 193
    Height = 66
    Caption = '[Info]'
    TabOrder = 6
    object lbEntryPoint: TLabeledEdit
      Left = 11
      Top = 32
      Width = 69
      Height = 21
      AutoSelect = False
      BevelKind = bkTile
      BorderStyle = bsNone
      CharCase = ecUpperCase
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.Caption = 'RVA of OEP'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -12
      EditLabel.Font.Name = 'Courier New'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
    object lbImageBase: TLabeledEdit
      Left = 116
      Top = 32
      Width = 69
      Height = 21
      AutoSelect = False
      BevelKind = bkTile
      BiDiMode = bdLeftToRight
      BorderStyle = bsNone
      CharCase = ecUpperCase
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.BiDiMode = bdLeftToRight
      EditLabel.Caption = 'Image Base'
      EditLabel.ParentBiDiMode = False
      ParentBiDiMode = False
      ReadOnly = True
      TabOrder = 1
    end
  end
  object XPManifest1: TXPManifest
    Left = 576
    Top = 280
  end
  object OpenDlg: TOpenDialog
    Filter = 'PE Files'
    Title = 'FLC'
    Left = 536
    Top = 280
  end
end
