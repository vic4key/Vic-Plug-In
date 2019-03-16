object frmModulePath: TfrmModulePath
  Left = 501
  Top = 111
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'Patch PEB for Module Filename'
  ClientHeight = 130
  ClientWidth = 274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Button1: TButton
    Left = 89
    Top = 97
    Width = 73
    Height = 25
    Caption = 'Patch'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 168
    Top = 97
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object lblFileName: TLabeledEdit
    Left = 8
    Top = 64
    Width = 233
    Height = 23
    EditLabel.Width = 63
    EditLabel.Height = 15
    EditLabel.Caption = 'Filename:'
    TabOrder = 2
  end
  object lblOldFileName: TLabeledEdit
    Left = 8
    Top = 24
    Width = 233
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 64
    EditLabel.Height = 13
    EditLabel.Caption = 'Old Filename:'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clGray
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 3
  end
  object Button3: TButton
    Left = 244
    Top = 64
    Width = 25
    Height = 23
    Caption = '...'
    TabOrder = 4
    OnClick = Button3Click
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'Executable Files (*.exe)|*.exe|DLL Files (*.dll)|*.dll|All Files' +
      ' (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 80
  end
end
