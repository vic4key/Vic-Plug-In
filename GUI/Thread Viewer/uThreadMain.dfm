object frmThreadViewer: TfrmThreadViewer
  Left = 0
  Top = 118
  BorderStyle = bsToolWindow
  Caption = 'Thread Viewer'
  ClientHeight = 506
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label20: TLabel
    Left = 8
    Top = 463
    Width = 42
    Height = 15
    Caption = 'Status'
  end
  object LbStatus: TLabel
    Left = 56
    Top = 463
    Width = 63
    Height = 15
    Caption = 'Something'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 137
    Caption = '[Threads]'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Label18: TLabel
      Left = 11
      Top = 24
      Width = 14
      Height = 15
      Caption = 'ID'
      Transparent = True
    end
    object Label19: TLabel
      Left = 11
      Top = 56
      Width = 35
      Height = 15
      Caption = 'Entry'
      Transparent = True
    end
    object LbEntry: TLabel
      Left = 150
      Top = 56
      Width = 73
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '00000000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label21: TLabel
      Left = 11
      Top = 75
      Width = 21
      Height = 15
      Caption = 'TIB'
      Transparent = True
    end
    object LbTIB: TLabel
      Left = 167
      Top = 75
      Width = 56
      Height = 15
      Alignment = taRightJustify
      Caption = '00000000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label23: TLabel
      Left = 11
      Top = 94
      Width = 56
      Height = 15
      Caption = 'Priority'
      Transparent = True
    end
    object LbPriority: TLabel
      Left = 216
      Top = 94
      Width = 7
      Height = 15
      Alignment = taRightJustify
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label25: TLabel
      Left = 11
      Top = 113
      Width = 42
      Height = 15
      Caption = 'Status'
      Transparent = True
    end
    object LbState: TLabel
      Left = 216
      Top = 113
      Width = 7
      Height = 15
      Alignment = taRightJustify
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object cbThreads: TComboBox
      Left = 41
      Top = 21
      Width = 182
      Height = 23
      Style = csDropDownList
      CharCase = ecUpperCase
      ItemHeight = 15
      TabOrder = 0
      OnChange = cbThreadsChange
      OnCloseUp = cbThreadsCloseUp
      OnDropDown = cbThreadsDropDown
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 151
    Width = 233
    Height = 66
    Caption = 'General-purpose Register'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 11
      Top = 19
      Width = 21
      Height = 15
      Caption = 'EAX'
      Transparent = True
    end
    object Label2: TLabel
      Left = 11
      Top = 39
      Width = 21
      Height = 15
      Caption = 'EBX'
      Transparent = True
    end
    object Label3: TLabel
      Left = 125
      Top = 19
      Width = 21
      Height = 15
      Caption = 'ECX'
      Transparent = True
    end
    object Label4: TLabel
      Left = 125
      Top = 39
      Width = 21
      Height = 15
      Caption = 'EDX'
      Transparent = True
    end
    object TxtEAX: TEdit
      Left = 41
      Top = 19
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 0
    end
    object TxtEBX: TEdit
      Left = 41
      Top = 39
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 1
    end
    object TxtECX: TEdit
      Left = 155
      Top = 19
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 2
    end
    object TxtEDX: TEdit
      Left = 155
      Top = 39
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 3
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 223
    Width = 233
    Height = 50
    Caption = 'Index Register'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label5: TLabel
      Left = 11
      Top = 19
      Width = 21
      Height = 15
      Caption = 'ESI'
      Transparent = True
    end
    object Label6: TLabel
      Left = 125
      Top = 19
      Width = 21
      Height = 15
      Caption = 'EDI'
      Transparent = True
    end
    object TxtESI: TEdit
      Left = 41
      Top = 19
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 0
    end
    object TxtEDI: TEdit
      Left = 155
      Top = 19
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 1
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 279
    Width = 233
    Height = 66
    Caption = 'Control Register'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object Label7: TLabel
      Left = 9
      Top = 20
      Width = 21
      Height = 15
      Caption = 'ESP'
      Transparent = True
    end
    object Label8: TLabel
      Left = 125
      Top = 19
      Width = 21
      Height = 15
      Caption = 'EBP'
      Transparent = True
    end
    object Label9: TLabel
      Left = 9
      Top = 39
      Width = 21
      Height = 15
      Caption = 'EIP'
      Transparent = True
    end
    object TxtESP: TEdit
      Left = 41
      Top = 19
      Width = 69
      Height = 14
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 0
    end
    object TxtEBP: TEdit
      Left = 155
      Top = 19
      Width = 69
      Height = 14
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 1
    end
    object TxtEIP: TEdit
      Left = 41
      Top = 39
      Width = 69
      Height = 14
      BorderStyle = bsNone
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 351
    Width = 233
    Height = 106
    Caption = 'Debug Register'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object Label10: TLabel
      Left = 9
      Top = 24
      Width = 21
      Height = 15
      Caption = 'Dr0'
      Transparent = True
    end
    object Label11: TLabel
      Left = 9
      Top = 43
      Width = 21
      Height = 15
      Caption = 'Dr1'
      Transparent = True
    end
    object Label12: TLabel
      Left = 9
      Top = 62
      Width = 21
      Height = 15
      Caption = 'Dr2'
      Transparent = True
    end
    object Label13: TLabel
      Left = 9
      Top = 81
      Width = 21
      Height = 15
      Caption = 'Dr3'
      Transparent = True
    end
    object Label14: TLabel
      Left = 125
      Top = 24
      Width = 21
      Height = 15
      Caption = 'Dr4'
      Transparent = True
    end
    object Label15: TLabel
      Left = 125
      Top = 43
      Width = 21
      Height = 15
      Caption = 'Dr5'
      Transparent = True
    end
    object Label16: TLabel
      Left = 125
      Top = 62
      Width = 21
      Height = 15
      Caption = 'Dr6'
      Transparent = True
    end
    object Label17: TLabel
      Left = 125
      Top = 81
      Width = 21
      Height = 15
      Caption = 'Dr7'
      Transparent = True
    end
    object TxtDr0: TEdit
      Left = 41
      Top = 24
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 0
    end
    object TxtDr1: TEdit
      Left = 41
      Top = 43
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 1
    end
    object TxtDr2: TEdit
      Left = 41
      Top = 62
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 2
    end
    object TxtDr3: TEdit
      Left = 41
      Top = 81
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 3
    end
    object TxtDr4: TEdit
      Left = 155
      Top = 23
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 4
    end
    object TxtDr5: TEdit
      Left = 155
      Top = 42
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 5
    end
    object TxtDr6: TEdit
      Left = 155
      Top = 61
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 6
    end
    object TxtDr7: TEdit
      Left = 155
      Top = 81
      Width = 69
      Height = 14
      AutoSelect = False
      BorderStyle = bsNone
      CharCase = ecUpperCase
      ReadOnly = True
      TabOrder = 7
    end
  end
  object chkbOnTop: TCheckBox
    Left = 8
    Top = 484
    Width = 111
    Height = 17
    Caption = 'Alway On Top'
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = chkbOnTopClick
  end
  object tmLoop: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmLoopTimer
    Left = 208
    Top = 480
  end
  object MainMenu1: TMainMenu
    Left = 152
    Top = 480
    object Action1: TMenuItem
      Caption = 'Action'
      object mnReload: TMenuItem
        Caption = 'Rebuild Thread List'
        OnClick = mnReloadClick
      end
      object mnStop: TMenuItem
        Caption = 'Stop'
        Enabled = False
        OnClick = mnStopClick
      end
      object mnResume: TMenuItem
        Caption = 'Resume'
        Enabled = False
        OnClick = mnResumeClick
      end
    end
    object Option1: TMenuItem
      Caption = 'Option'
      object mnTimer: TMenuItem
        Caption = 'Timer'
        OnClick = mnTimerClick
      end
    end
  end
end
