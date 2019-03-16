object frmUpdater: TfrmUpdater
  Left = 0
  Top = 219
  BorderStyle = bsToolWindow
  Caption = 'Vic'#39's Updater'
  ClientHeight = 304
  ClientWidth = 377
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
  object Label1: TLabel
    Left = 8
    Top = 146
    Width = 42
    Height = 15
    Caption = 'Status'
    Transparent = True
  end
  object LbStatus: TLabel
    Left = 62
    Top = 146
    Width = 307
    Height = 15
    AutoSize = False
    Caption = 'Idle'
    Transparent = True
  end
  object Label5: TLabel
    Left = 8
    Top = 171
    Width = 112
    Height = 15
    Caption = 'Downloaded files'
    Transparent = True
  end
  object BtnStart: TButton
    Left = 8
    Top = 271
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = BtnStartClick
  end
  object ProgressBarDownload: TProgressBar
    Left = 8
    Top = 122
    Width = 361
    Height = 18
    TabOrder = 1
  end
  object List: TMemo
    Left = 8
    Top = 191
    Width = 361
    Height = 74
    ReadOnly = True
    TabOrder = 2
  end
  object TrvDoc: TTreeView
    Left = 8
    Top = 320
    Width = 361
    Height = 68
    Indent = 19
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 361
    Height = 108
    Caption = '[Info]'
    TabOrder = 4
    object Label2: TLabel
      Left = 12
      Top = 19
      Width = 63
      Height = 15
      Caption = 'File Name'
      Transparent = True
    end
    object LbFileName: TLabel
      Left = 92
      Top = 19
      Width = 42
      Height = 15
      Caption = '<NONE>'
      Transparent = True
    end
    object LbFileSize: TLabel
      Left = 92
      Top = 40
      Width = 260
      Height = 13
      AutoSize = False
      Caption = '<NONE>'
      Transparent = True
    end
    object LbDownloaded: TLabel
      Left = 92
      Top = 61
      Width = 260
      Height = 13
      AutoSize = False
      Caption = '<NONE>'
      Transparent = True
    end
    object Label4: TLabel
      Left = 12
      Top = 40
      Width = 63
      Height = 15
      Caption = 'File Size'
      Transparent = True
    end
    object Label7: TLabel
      Left = 12
      Top = 61
      Width = 70
      Height = 15
      Caption = 'Downloaded'
      Transparent = True
    end
    object Label3: TLabel
      Left = 12
      Top = 82
      Width = 70
      Height = 15
      Caption = 'File count'
      Transparent = True
    end
    object LbFileCount: TLabel
      Left = 92
      Top = 82
      Width = 42
      Height = 15
      Caption = '<NONE>'
      Transparent = True
    end
    object Label6: TLabel
      Left = 12
      Top = 138
      Width = 56
      Height = 15
      Caption = 'Save dir'
      Transparent = True
    end
    object txtSaveDir: TEdit
      Left = 92
      Top = 138
      Width = 260
      Height = 18
      AutoSelect = False
      AutoSize = False
      BorderStyle = bsNone
      ReadOnly = True
      TabOrder = 0
    end
  end
  object chkOnTop: TCheckBox
    Left = 249
    Top = 277
    Width = 120
    Height = 17
    Caption = 'Always On Top'
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = chkOnTopClick
  end
end
