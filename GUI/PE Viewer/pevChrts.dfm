object Crtics: TCrtics
  Left = 334
  Top = 112
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'Characteristics'
  ClientHeight = 304
  ClientWidth = 309
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 350
    Width = 109
    Height = 13
    AutoSize = False
    Caption = '???'
  end
  object GroupBox1: TGroupBox
    Left = 12
    Top = 12
    Width = 285
    Height = 257
    Caption = '[IMAGE FILE]'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object CheckBox1: TCheckBox
      Left = 12
      Top = 20
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_RELOCS_STRIPPED'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 12
      Top = 36
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_EXECUTABLE_IMAGE'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 12
      Top = 52
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_LINE_NUMS_STRIPPED'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object CheckBox4: TCheckBox
      Left = 12
      Top = 68
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_LOCAL_SYMS_STRIPPED'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object CheckBox5: TCheckBox
      Left = 12
      Top = 84
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_AGGRESIVE_WS_TRIM'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object CheckBox6: TCheckBox
      Left = 12
      Top = 100
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_BYTES_REVERSED_LO'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
    end
    object CheckBox7: TCheckBox
      Left = 12
      Top = 116
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_32BIT_MACHINE'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object CheckBox8: TCheckBox
      Left = 12
      Top = 132
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_DEBUG_STRIPPED'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
    end
    object CheckBox9: TCheckBox
      Left = 12
      Top = 148
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
    end
    object CheckBox10: TCheckBox
      Left = 12
      Top = 164
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_NET_RUN_FROM_SWAP'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object CheckBox11: TCheckBox
      Left = 12
      Top = 180
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_SYSTEM'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
    end
    object CheckBox12: TCheckBox
      Left = 12
      Top = 196
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_DLL'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
    end
    object CheckBox13: TCheckBox
      Left = 12
      Top = 212
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_UP_SYSTEM_ONLY'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
    end
    object CheckBox14: TCheckBox
      Left = 12
      Top = 228
      Width = 265
      Height = 17
      Caption = 'IMAGE_FILE_BYTES_REVERSED_HI'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
    end
  end
  object Button1: TButton
    Left = 120
    Top = 275
    Width = 65
    Height = 21
    Caption = 'Re-Load'
    TabOrder = 1
    OnClick = Button1Click
  end
end
