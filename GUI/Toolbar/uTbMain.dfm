object frmTB: TfrmTB
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'frmTB'
  ClientHeight = 26
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object btnNotepad: TButton
    Left = 0
    Top = -1
    Width = 65
    Height = 22
    Caption = 'Notepad'
    TabOrder = 0
    OnClick = btnNotepadClick
  end
  object btnFolder: TButton
    Left = 71
    Top = -1
    Width = 60
    Height = 22
    Caption = 'Folder'
    TabOrder = 1
    OnClick = btnFolderClick
  end
  object btnCalc: TButton
    Left = 137
    Top = -1
    Width = 40
    Height = 22
    Caption = 'Calc'
    TabOrder = 2
    OnClick = btnCalcClick
  end
  object btnCmd: TButton
    Left = 183
    Top = -1
    Width = 35
    Height = 22
    Caption = 'Cmd'
    TabOrder = 3
    OnClick = btnCmdClick
  end
  object btnExit: TButton
    Left = 224
    Top = -1
    Width = 36
    Height = 22
    Caption = 'Exit'
    TabOrder = 4
    OnClick = btnExitClick
  end
  object gfc: TEdit
    Left = 8
    Top = 27
    Width = 204
    Height = 23
    TabOrder = 5
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 8
    Top = 56
  end
end
