object frmMain: TfrmMain
  Left = 323
  Top = 192
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'PEB Patcher'
  ClientHeight = 484
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
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
  object Splitter1: TSplitter
    Left = 0
    Top = 361
    Width = 745
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 289
    ExplicitWidth = 749
  end
  object pnlProcesses: TPanel
    Left = 0
    Top = 0
    Width = 745
    Height = 361
    Align = alClient
    TabOrder = 0
    object lvProcesses: TListView
      Left = 1
      Top = 1
      Width = 743
      Height = 359
      Align = alClient
      Columns = <
        item
          Caption = 'PID'
        end
        item
          Caption = 'ProcessName'
          Width = 120
        end
        item
          Caption = 'Image Path'
          Width = 250
        end
        item
          Caption = 'Description'
          Width = 200
        end
        item
          Caption = 'Company'
          Width = 120
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      GridLines = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      PopupMenu = PopupMenu1
      ShowWorkAreas = True
      SmallImages = ImageList1
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lvProcessesClick
    end
  end
  object pnlModules: TPanel
    Left = 0
    Top = 364
    Width = 745
    Height = 120
    Align = alBottom
    TabOrder = 1
    object lvModules: TListView
      Left = 1
      Top = 1
      Width = 743
      Height = 99
      Align = alClient
      Columns = <
        item
          Caption = 'ModuleName'
          Width = 90
        end
        item
          Caption = 'ModulePath'
          Width = 330
        end
        item
          Caption = 'Description'
          Width = 200
        end
        item
          Caption = 'Company'
          Width = 120
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      PopupMenu = PopupMenu2
      ShowWorkAreas = True
      SmallImages = ImageList1
      TabOrder = 0
      ViewStyle = vsReport
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 100
      Width = 743
      Height = 19
      Panels = <
        item
          Text = 'Processes: 0'
          Width = 85
        end
        item
          Text = 'Modules: 0'
          Width = 80
        end
        item
          Text = 'Idle'
          Width = 250
        end>
    end
  end
  object cbOnTop: TCheckBox
    Left = 688
    Top = 465
    Width = 57
    Height = 17
    Caption = 'On Top'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = cbOnTopClick
  end
  object tRefresh: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tRefreshTimer
    Left = 16
    Top = 24
  end
  object ImageList1: TImageList
    Left = 48
    Top = 24
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 80
    Top = 24
    object PatchImagePath1: TMenuItem
      Caption = 'Patch Image Path'
      OnClick = PatchImagePath1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 16
    Top = 320
    object PatchModuleFilename1: TMenuItem
      Caption = 'Patch Module Filename'
      OnClick = PatchModuleFilename1Click
    end
  end
end
