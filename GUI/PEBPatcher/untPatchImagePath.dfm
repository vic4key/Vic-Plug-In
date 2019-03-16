object frmImagePath: TfrmImagePath
  Left = 214
  Top = 114
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'Patch PEB for Image Path'
  ClientHeight = 97
  ClientWidth = 275
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
    Top = 64
    Width = 73
    Height = 25
    Caption = 'Patch'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 168
    Top = 64
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
  object lblFileName: TLabeledEdit
    Left = 8
    Top = 32
    Width = 233
    Height = 23
    EditLabel.Width = 63
    EditLabel.Height = 15
    EditLabel.Caption = 'Filename:'
    TabOrder = 0
  end
  object Button3: TButton
    Left = 244
    Top = 32
    Width = 25
    Height = 23
    Caption = '...'
    TabOrder = 1
    OnClick = Button3Click
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'Executable Files (*.exe)|*.exe|DLL Files (*.dll)|*.dll|All Files' +
      ' (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 56
  end
end
