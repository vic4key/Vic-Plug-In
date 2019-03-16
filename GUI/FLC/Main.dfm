object frmFLC: TfrmFLC
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 206
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbEntryPoint: TLabel
    Left = 8
    Top = 135
    Width = 76
    Height = 13
    Caption = 'RVA Entry Point'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 145
    Height = 121
    Caption = '[Address converter]'
    TabOrder = 0
    object rdOffset: TRadioButton
      Left = 16
      Top = 24
      Width = 57
      Height = 17
      Caption = 'Offset'
      Checked = True
      TabOrder = 0
      TabStop = True
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
      TabOrder = 2
      OnClick = rdVAClick
    end
    object txtOffset: TEdit
      Left = 79
      Top = 22
      Width = 58
      Height = 21
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      TabOrder = 3
      OnChange = txtOffsetChange
      OnKeyPress = txtOffsetKeyPress
    end
    object txtRVA: TEdit
      Left = 79
      Top = 53
      Width = 58
      Height = 21
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      ReadOnly = True
      TabOrder = 4
      OnChange = txtRVAChange
      OnKeyPress = txtRVAKeyPress
    end
    object txtVA: TEdit
      Left = 79
      Top = 86
      Width = 58
      Height = 21
      AutoSelect = False
      CharCase = ecUpperCase
      MaxLength = 8
      ReadOnly = True
      TabOrder = 5
      OnChange = txtVAChange
      OnKeyPress = txtVAKeyPress
    end
  end
  object GroupBox2: TGroupBox
    Left = 159
    Top = 8
    Width = 474
    Height = 172
    Caption = '[Sections Infomation]'
    TabOrder = 1
    object lSInfo: TListView
      Left = 16
      Top = 22
      Width = 449
      Height = 139
      Align = alCustom
      Columns = <
        item
          Caption = 'Name'
        end
        item
          Caption = 'Virtual Address'
          Width = 87
        end
        item
          Caption = 'Virtual Size'
          Width = 69
        end
        item
          Caption = 'Raw Address'
          Width = 81
        end
        item
          Caption = 'Raw Size'
          Width = 61
        end
        item
          Caption = 'Characteristics'
          Width = 95
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
    Left = 8
    Top = 154
    Width = 145
    Height = 26
    Caption = '[Open]'
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object cbOnTop: TCheckBox
    Left = 8
    Top = 186
    Width = 97
    Height = 17
    Caption = 'Stay On Top'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbOnTopClick
  end
  object XPManifest1: TXPManifest
    Left = 616
    Top = 176
  end
  object OpenDlg: TOpenDialog
    Filter = 'PE Files'
    Title = 'FLC'
    Left = 584
    Top = 184
  end
end
