object DLLPV: TDLLPV
  Left = 241
  Top = 191
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'DLL Process Viewer'
  ClientHeight = 484
  ClientWidth = 724
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 280
    Top = 152
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 280
    Top = 144
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 484
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitHeight = 423
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 183
      Height = 35
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object create_: TButton
        Left = 7
        Top = 4
        Width = 105
        Height = 25
        Caption = 'Process List'
        TabOrder = 0
        OnClick = create_Click
      end
      object cbOnTop: TCheckBox
        Left = 118
        Top = 10
        Width = 60
        Height = 13
        Caption = 'On Top'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbOnTopClick
      end
    end
    object process_listbox_: TListBox
      Left = 1
      Top = 36
      Width = 183
      Height = 447
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 15
      ParentFont = False
      TabOrder = 1
      OnClick = process_listbox_Click
      ExplicitHeight = 386
    end
  end
  object PageControl1: TPageControl
    Left = 185
    Top = 0
    Width = 539
    Height = 484
    ActivePage = detail_
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = PageControl1Change
    ExplicitWidth = 460
    ExplicitHeight = 423
    object display__: TTabSheet
      Caption = 'Display'
      ExplicitTop = 24
      ExplicitWidth = 452
      ExplicitHeight = 395
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 531
        Height = 454
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = Memo1Change
        ExplicitWidth = 452
        ExplicitHeight = 395
      end
    end
    object detail_: TTabSheet
      Caption = 'Detail'
      ImageIndex = 1
      ExplicitTop = 24
      ExplicitWidth = 452
      ExplicitHeight = 395
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 531
        Height = 95
        Align = alTop
        Caption = 'Panel6'
        TabOrder = 0
        ExplicitWidth = 452
        object process_memo_: TMemo
          Left = 1
          Top = 1
          Width = 529
          Height = 93
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitWidth = 450
        end
      end
      object Panel8: TPanel
        Left = 0
        Top = 413
        Width = 531
        Height = 41
        Align = alBottom
        TabOrder = 1
        Visible = False
        ExplicitTop = 354
        ExplicitWidth = 452
      end
      object PageControl2: TPageControl
        Left = 0
        Top = 95
        Width = 531
        Height = 318
        ActivePage = mapped_files_
        Align = alClient
        TabOrder = 2
        ExplicitWidth = 452
        ExplicitHeight = 259
        object dll_: TTabSheet
          Caption = 'DLL'
          ExplicitTop = 24
          ExplicitWidth = 444
          ExplicitHeight = 231
          object Splitter1: TSplitter
            Left = 169
            Top = 0
            Width = 2
            Height = 288
            Color = clYellow
            ParentColor = False
            ExplicitHeight = 285
          end
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 169
            Height = 288
            Align = alLeft
            Caption = 'Panel4'
            TabOrder = 0
            ExplicitHeight = 231
            object Panel5: TPanel
              Left = 1
              Top = 1
              Width = 167
              Height = 31
              Align = alTop
              TabOrder = 0
              object module_count_label_: TLabel
                Left = 135
                Top = 10
                Width = 7
                Height = 15
                Caption = '0'
              end
              object Label3: TLabel
                Left = 82
                Top = 10
                Width = 70
                Height = 15
                Caption = 'Total DLL:'
              end
              object sort_dll_: TCheckBox
                Left = 8
                Top = 8
                Width = 65
                Height = 17
                Caption = 'Sort DLL'
                TabOrder = 0
                OnClick = sort_dll_Click
              end
            end
            object module_listbox_: TListBox
              Left = 1
              Top = 32
              Width = 167
              Height = 255
              Align = alClient
              ItemHeight = 15
              TabOrder = 1
              OnClick = module_listbox_Click
              ExplicitHeight = 198
            end
          end
          object module_memo_: TMemo
            Left = 171
            Top = 0
            Width = 352
            Height = 288
            Align = alClient
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 1
            ExplicitWidth = 273
            ExplicitHeight = 231
          end
        end
        object mapped_files_: TTabSheet
          Caption = 'Mapped Files'
          ImageIndex = 1
          ExplicitTop = 24
          ExplicitWidth = 444
          ExplicitHeight = 231
          object Splitter2: TSplitter
            Left = 185
            Top = 0
            Width = 2
            Height = 288
            Color = clYellow
            ParentColor = False
            ExplicitHeight = 285
          end
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 185
            Height = 288
            Align = alLeft
            Caption = 'Panel7'
            TabOrder = 0
            ExplicitHeight = 231
            object Panel9: TPanel
              Left = 1
              Top = 1
              Width = 183
              Height = 31
              Align = alTop
              TabOrder = 0
              object build_mmf_: TCheckBox
                Left = 8
                Top = 8
                Width = 81
                Height = 17
                Caption = 'Build MMF'
                TabOrder = 0
              end
            end
            object memory_mapped_file_listbox_: TListBox
              Left = 1
              Top = 32
              Width = 183
              Height = 255
              Align = alClient
              ItemHeight = 15
              TabOrder = 1
              OnClick = memory_mapped_file_listbox_Click
              ExplicitHeight = 198
            end
          end
          object memory_mapped_file_memo_: TMemo
            Left = 187
            Top = 0
            Width = 336
            Height = 288
            Align = alClient
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 1
            ExplicitWidth = 257
            ExplicitHeight = 231
          end
        end
      end
    end
  end
  object XPManifest1: TXPManifest
    Left = 312
    Top = 240
  end
end
