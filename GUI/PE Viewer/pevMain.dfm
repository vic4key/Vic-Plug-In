object PE_Viewer: TPE_Viewer
  Left = 167
  Top = 76
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'PE Viewer'
  ClientHeight = 583
  ClientWidth = 906
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
    Top = 51
    Width = 600
    Height = 177
    Caption = '[Image Dos Header]'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    object Label1: TLabel
      Left = 48
      Top = 22
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Magic Number'
      Transparent = True
    end
    object Label2: TLabel
      Left = 6
      Top = 43
      Width = 126
      Height = 15
      Alignment = taRightJustify
      Caption = 'Bytes on last page'
      Transparent = True
    end
    object Label3: TLabel
      Left = 41
      Top = 64
      Width = 91
      Height = 15
      Alignment = taRightJustify
      Caption = 'Pages in file'
      Transparent = True
    end
    object Label4: TLabel
      Left = 55
      Top = 85
      Width = 77
      Height = 15
      Alignment = taRightJustify
      Caption = 'Relocations'
      Transparent = True
    end
    object Label5: TLabel
      Left = 34
      Top = 106
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of header'
      Transparent = True
    end
    object Label6: TLabel
      Left = 34
      Top = 127
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'Minimum memory'
      Transparent = True
    end
    object Label7: TLabel
      Left = 34
      Top = 148
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'Maximum memory'
      Transparent = True
    end
    object Label8: TLabel
      Left = 218
      Top = 22
      Width = 112
      Height = 15
      Alignment = taRightJustify
      Caption = 'Initial SS value'
      Transparent = True
    end
    object Label9: TLabel
      Left = 218
      Top = 43
      Width = 112
      Height = 15
      Alignment = taRightJustify
      Caption = 'Initial SP value'
      Transparent = True
    end
    object Label10: TLabel
      Left = 274
      Top = 64
      Width = 56
      Height = 15
      Alignment = taRightJustify
      Caption = 'Checksum'
      Transparent = True
    end
    object Label11: TLabel
      Left = 218
      Top = 86
      Width = 112
      Height = 15
      Alignment = taRightJustify
      Caption = 'Initial IP value'
      Transparent = True
    end
    object Label12: TLabel
      Left = 218
      Top = 107
      Width = 112
      Height = 15
      Alignment = taRightJustify
      Caption = 'Initial CS value'
      Transparent = True
    end
    object Label13: TLabel
      Left = 246
      Top = 128
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Table offset'
      Transparent = True
    end
    object Label14: TLabel
      Left = 228
      Top = 149
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'Overlay number'
      Transparent = True
    end
    object Label15: TLabel
      Left = 417
      Top = 21
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'OEM identifier'
      Transparent = True
    end
    object Label16: TLabel
      Left = 410
      Top = 42
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'OEM information'
      Transparent = True
    end
    object Label17: TLabel
      Left = 445
      Top = 63
      Width = 70
      Height = 15
      Alignment = taRightJustify
      Caption = 'PE Address'
      Transparent = True
    end
    object Edit1: TEdit
      Left = 138
      Top = 18
      Width = 69
      Height = 23
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 138
      Top = 37
      Width = 69
      Height = 23
      TabOrder = 1
    end
    object Edit3: TEdit
      Left = 138
      Top = 56
      Width = 69
      Height = 23
      TabOrder = 2
    end
    object Edit4: TEdit
      Left = 138
      Top = 77
      Width = 69
      Height = 23
      TabOrder = 3
    end
    object Edit5: TEdit
      Left = 138
      Top = 98
      Width = 69
      Height = 23
      TabOrder = 4
    end
    object Edit6: TEdit
      Left = 138
      Top = 120
      Width = 69
      Height = 23
      TabOrder = 5
    end
    object Edit7: TEdit
      Left = 138
      Top = 141
      Width = 69
      Height = 23
      TabOrder = 6
    end
    object Edit8: TEdit
      Left = 332
      Top = 18
      Width = 69
      Height = 23
      TabOrder = 7
    end
    object Edit9: TEdit
      Left = 332
      Top = 39
      Width = 69
      Height = 23
      TabOrder = 8
    end
    object Edit10: TEdit
      Left = 332
      Top = 60
      Width = 69
      Height = 23
      TabOrder = 9
    end
    object Edit11: TEdit
      Left = 332
      Top = 82
      Width = 69
      Height = 23
      TabOrder = 10
    end
    object Edit12: TEdit
      Left = 332
      Top = 103
      Width = 69
      Height = 23
      TabOrder = 11
    end
    object Edit13: TEdit
      Left = 332
      Top = 124
      Width = 69
      Height = 23
      TabOrder = 12
    end
    object Edit14: TEdit
      Left = 332
      Top = 146
      Width = 69
      Height = 23
      TabOrder = 13
    end
    object Edit15: TEdit
      Left = 521
      Top = 19
      Width = 69
      Height = 23
      TabOrder = 14
    end
    object Edit16: TEdit
      Left = 521
      Top = 39
      Width = 69
      Height = 23
      TabOrder = 15
    end
    object Edit17: TEdit
      Left = 521
      Top = 58
      Width = 69
      Height = 23
      TabOrder = 16
    end
    object GroupBox6: TGroupBox
      Left = 449
      Top = 84
      Width = 141
      Height = 57
      Caption = '[I/E Tables]'
      TabOrder = 17
      object Button4: TButton
        Left = 12
        Top = 20
        Width = 53
        Height = 25
        Caption = 'Import'
        TabOrder = 0
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 76
        Top = 20
        Width = 51
        Height = 25
        Caption = 'Export'
        TabOrder = 1
        OnClick = Button5Click
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 614
    Top = 53
    Width = 283
    Height = 177
    Caption = '[Image File Header]'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    object Label18: TLabel
      Left = 125
      Top = 21
      Width = 49
      Height = 15
      Alignment = taRightJustify
      Caption = 'Machine'
      Transparent = True
    end
    object Label19: TLabel
      Left = 48
      Top = 42
      Width = 126
      Height = 15
      Alignment = taRightJustify
      Caption = 'Number of Sections'
      Transparent = True
    end
    object Label20: TLabel
      Left = 69
      Top = 63
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Time Date Stamp'
      Transparent = True
    end
    object Label21: TLabel
      Left = 13
      Top = 85
      Width = 161
      Height = 15
      Alignment = taRightJustify
      Caption = 'Pointer to Symbol table'
      Transparent = True
    end
    object Label22: TLabel
      Left = 55
      Top = 106
      Width = 119
      Height = 15
      Alignment = taRightJustify
      Caption = 'Number of Symbols'
      Transparent = True
    end
    object Label23: TLabel
      Left = 13
      Top = 127
      Width = 161
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Optional Header'
      Transparent = True
    end
    object Label24: TLabel
      Left = 69
      Top = 149
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Characteristics'
      Transparent = True
    end
    object Edit18: TEdit
      Left = 180
      Top = 18
      Width = 69
      Height = 23
      TabOrder = 0
      Text = 'FFFFFFFF'
    end
    object Edit19: TEdit
      Left = 180
      Top = 39
      Width = 69
      Height = 23
      TabOrder = 1
    end
    object Edit20: TEdit
      Left = 180
      Top = 60
      Width = 69
      Height = 23
      TabOrder = 2
    end
    object Edit21: TEdit
      Left = 180
      Top = 82
      Width = 69
      Height = 23
      TabOrder = 3
    end
    object Edit22: TEdit
      Left = 180
      Top = 103
      Width = 69
      Height = 23
      TabOrder = 4
    end
    object Edit23: TEdit
      Left = 180
      Top = 124
      Width = 69
      Height = 23
      TabOrder = 5
    end
    object Edit24: TEdit
      Left = 180
      Top = 146
      Width = 69
      Height = 23
      ReadOnly = True
      TabOrder = 6
      Text = 'FFFFFFFF'
    end
    object Button3: TButton
      Left = 255
      Top = 147
      Width = 21
      Height = 21
      Caption = '>'
      TabOrder = 7
      OnClick = Button3Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 229
    Width = 889
    Height = 205
    Caption = '[Image Optinal Header]'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 2
    object Label25: TLabel
      Left = 108
      Top = 21
      Width = 35
      Height = 15
      Alignment = taRightJustify
      Caption = 'Magic'
      Transparent = True
    end
    object Label26: TLabel
      Left = 10
      Top = 42
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Major Linker Verion'
      Transparent = True
    end
    object Label27: TLabel
      Left = 10
      Top = 64
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Minor Linker Verion'
      Transparent = True
    end
    object Label28: TLabel
      Left = 59
      Top = 86
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Code'
      Transparent = True
    end
    object Label29: TLabel
      Left = 3
      Top = 107
      Width = 140
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Initial Date'
      Transparent = True
    end
    object Label30: TLabel
      Left = 10
      Top = 129
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Uninit Data'
      Transparent = True
    end
    object Label31: TLabel
      Left = 17
      Top = 151
      Width = 126
      Height = 15
      Alignment = taRightJustify
      Caption = 'Addr of EntryPoint'
      Transparent = True
    end
    object Label32: TLabel
      Left = 59
      Top = 173
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Base of Code'
      Transparent = True
    end
    object Label33: TLabel
      Left = 274
      Top = 24
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Base of Data'
      Transparent = True
    end
    object Label34: TLabel
      Left = 295
      Top = 45
      Width = 63
      Height = 15
      Alignment = taRightJustify
      Caption = 'ImageBase'
      Transparent = True
    end
    object Label35: TLabel
      Left = 239
      Top = 67
      Width = 119
      Height = 15
      Alignment = taRightJustify
      Caption = 'Section Alignment'
      Transparent = True
    end
    object Label36: TLabel
      Left = 260
      Top = 88
      Width = 98
      Height = 15
      Alignment = taRightJustify
      Caption = 'File Alignment'
      Transparent = True
    end
    object Label37: TLabel
      Left = 253
      Top = 109
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Major OS Verion'
      Transparent = True
    end
    object Label38: TLabel
      Left = 253
      Top = 131
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Minor OS Verion'
      Transparent = True
    end
    object Label39: TLabel
      Left = 225
      Top = 155
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Major Image Version'
      Transparent = True
    end
    object Label40: TLabel
      Left = 225
      Top = 176
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Minor Image Version'
      Transparent = True
    end
    object Label41: TLabel
      Left = 438
      Top = 23
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Major SubSys Verion'
      Transparent = True
    end
    object Label42: TLabel
      Left = 438
      Top = 45
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Minor SubSys Verion'
      Transparent = True
    end
    object Label43: TLabel
      Left = 438
      Top = 66
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Win32 Version Value'
      Transparent = True
    end
    object Label44: TLabel
      Left = 480
      Top = 87
      Width = 91
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Image'
      Transparent = True
    end
    object Label45: TLabel
      Left = 466
      Top = 109
      Width = 105
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Headers'
      Transparent = True
    end
    object Label46: TLabel
      Left = 515
      Top = 133
      Width = 56
      Height = 15
      Alignment = taRightJustify
      Caption = 'Checksum'
      Transparent = True
    end
    object Label47: TLabel
      Left = 508
      Top = 154
      Width = 63
      Height = 15
      Alignment = taRightJustify
      Caption = 'Subsystem'
      Transparent = True
    end
    object Label48: TLabel
      Left = 438
      Top = 175
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Dll Characteristics'
      Transparent = True
    end
    object Label49: TLabel
      Left = 655
      Top = 33
      Width = 147
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Stack Reserve'
      Transparent = True
    end
    object Label50: TLabel
      Left = 662
      Top = 57
      Width = 140
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Stack Commit'
      Transparent = True
    end
    object Label51: TLabel
      Left = 662
      Top = 82
      Width = 140
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Heap Reserve'
      Transparent = True
    end
    object Label52: TLabel
      Left = 669
      Top = 106
      Width = 133
      Height = 15
      Alignment = taRightJustify
      Caption = 'Size of Heap Commit'
      Transparent = True
    end
    object Label53: TLabel
      Left = 718
      Top = 131
      Width = 84
      Height = 15
      Alignment = taRightJustify
      Caption = 'Loader Flags'
      Transparent = True
    end
    object Label54: TLabel
      Left = 652
      Top = 159
      Width = 147
      Height = 15
      Alignment = taRightJustify
      Caption = 'Number of RVA && Sizes'
      Transparent = True
    end
    object Edit25: TEdit
      Left = 148
      Top = 20
      Width = 70
      Height = 23
      TabOrder = 0
    end
    object Edit26: TEdit
      Left = 148
      Top = 41
      Width = 70
      Height = 23
      TabOrder = 1
    end
    object Edit27: TEdit
      Left = 148
      Top = 63
      Width = 70
      Height = 23
      TabOrder = 2
    end
    object Edit28: TEdit
      Left = 148
      Top = 85
      Width = 70
      Height = 23
      TabOrder = 3
    end
    object Edit29: TEdit
      Left = 148
      Top = 106
      Width = 70
      Height = 23
      TabOrder = 4
    end
    object Edit30: TEdit
      Left = 148
      Top = 128
      Width = 70
      Height = 23
      TabOrder = 5
    end
    object Edit31: TEdit
      Left = 148
      Top = 150
      Width = 70
      Height = 23
      TabOrder = 6
    end
    object Edit32: TEdit
      Left = 148
      Top = 172
      Width = 70
      Height = 23
      TabOrder = 7
    end
    object Edit33: TEdit
      Left = 362
      Top = 23
      Width = 70
      Height = 23
      TabOrder = 8
    end
    object Edit34: TEdit
      Left = 362
      Top = 44
      Width = 70
      Height = 23
      TabOrder = 9
    end
    object Edit35: TEdit
      Left = 362
      Top = 66
      Width = 70
      Height = 23
      TabOrder = 10
    end
    object Edit36: TEdit
      Left = 362
      Top = 88
      Width = 70
      Height = 23
      TabOrder = 11
    end
    object Edit37: TEdit
      Left = 362
      Top = 109
      Width = 70
      Height = 23
      TabOrder = 12
    end
    object Edit38: TEdit
      Left = 362
      Top = 131
      Width = 70
      Height = 23
      TabOrder = 13
    end
    object Edit39: TEdit
      Left = 362
      Top = 153
      Width = 70
      Height = 23
      TabOrder = 14
    end
    object Edit40: TEdit
      Left = 362
      Top = 175
      Width = 70
      Height = 23
      TabOrder = 15
    end
    object Edit41: TEdit
      Left = 575
      Top = 22
      Width = 70
      Height = 23
      TabOrder = 16
    end
    object Edit42: TEdit
      Left = 575
      Top = 44
      Width = 70
      Height = 23
      TabOrder = 17
    end
    object Edit43: TEdit
      Left = 575
      Top = 65
      Width = 70
      Height = 23
      TabOrder = 18
    end
    object Edit44: TEdit
      Left = 575
      Top = 86
      Width = 70
      Height = 23
      TabOrder = 19
    end
    object Edit45: TEdit
      Left = 575
      Top = 108
      Width = 70
      Height = 23
      TabOrder = 20
    end
    object Edit46: TEdit
      Left = 575
      Top = 130
      Width = 70
      Height = 23
      TabOrder = 21
    end
    object Edit47: TEdit
      Left = 575
      Top = 151
      Width = 70
      Height = 23
      TabOrder = 22
    end
    object Edit48: TEdit
      Left = 575
      Top = 172
      Width = 70
      Height = 23
      TabOrder = 23
    end
    object Edit49: TEdit
      Left = 805
      Top = 32
      Width = 75
      Height = 23
      TabOrder = 24
    end
    object Edit50: TEdit
      Left = 805
      Top = 56
      Width = 75
      Height = 23
      TabOrder = 25
    end
    object Edit51: TEdit
      Left = 805
      Top = 81
      Width = 75
      Height = 23
      TabOrder = 26
    end
    object Edit52: TEdit
      Left = 805
      Top = 106
      Width = 75
      Height = 23
      TabOrder = 27
    end
    object Edit53: TEdit
      Left = 805
      Top = 131
      Width = 75
      Height = 23
      TabOrder = 28
    end
    object Edit54: TEdit
      Left = 805
      Top = 152
      Width = 75
      Height = 23
      TabOrder = 29
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 433
    Width = 889
    Height = 121
    Caption = '[SECTIONS]'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 3
    object ListView1: TListView
      Left = 8
      Top = 16
      Width = 872
      Height = 97
      Columns = <
        item
          Caption = 'NO'
          Width = 39
        end
        item
          Caption = 'Section '
          Width = 83
        end
        item
          Caption = 'Physical Address'
          Width = 143
        end
        item
          Caption = 'Virtual Address'
          Width = 129
        end
        item
          Caption = 'Virtual Size'
          Width = 119
        end
        item
          Caption = 'RAW Offset'
          Width = 114
        end
        item
          Caption = 'RAW Size'
          Width = 96
        end
        item
          Caption = 'Characteristics'
          Width = 144
        end>
      ColumnClick = False
      FlatScrollBars = True
      GridLines = True
      ReadOnly = True
      RowSelect = True
      ShowWorkAreas = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 6
    Width = 889
    Height = 41
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 4
    object Edit55: TEdit
      Left = 8
      Top = 12
      Width = 744
      Height = 23
      TabOrder = 0
      Text = 'Please drag and drop a file or select a PE file first ...'
    end
    object Button1: TButton
      Left = 758
      Top = 11
      Width = 55
      Height = 23
      Caption = 'Open'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 816
      Top = 11
      Width = 65
      Height = 23
      Caption = 'Re-Load'
      TabOrder = 2
      OnClick = Button2Click
    end
  end
  object cbOnTop: TCheckBox
    Left = 8
    Top = 560
    Width = 121
    Height = 17
    Caption = 'Always On Top'
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = cbOnTopClick
  end
  object OpenDialog1: TOpenDialog
    Filter = '??PE??|*.exe;*.dll;*.ocx;*.vxd;*.sys;*.drv|????|*.*'
    Left = 480
    Top = 24
  end
  object XPManifest1: TXPManifest
    Left = 800
    Top = 576
  end
end
