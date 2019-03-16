object IETable: TIETable
  Left = 235
  Top = 208
  AlphaBlend = True
  AlphaBlendValue = 240
  BorderStyle = bsToolWindow
  Caption = 'Import/Export Table Viewer'
  ClientHeight = 309
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 489
    Height = 293
    ActivePage = TabSheet1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Import Table'
      ExplicitWidth = 473
      object ListView1: TListView
        Left = 4
        Top = 4
        Width = 469
        Height = 257
        Columns = <
          item
            Caption = 'API Function Name / ID'
            Width = 169
          end
          item
            Caption = 'Module Name'
            Width = 123
          end
          item
            Caption = 'Hint'
            Width = 70
          end
          item
            Caption = 'Thunk Value'
            Width = 100
          end>
        FlatScrollBars = True
        GridLines = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Export Table'
      ImageIndex = 1
      ExplicitLeft = 20
      ExplicitTop = 82
      ExplicitWidth = 489
      object ListView2: TListView
        Left = 4
        Top = 4
        Width = 474
        Height = 257
        Columns = <
          item
            Caption = 'Function Name'
            Width = 150
          end
          item
            Caption = 'Function ID / Num'
            Width = 176
          end
          item
            Caption = 'Thunk Value'
            Width = 138
          end>
        ColumnClick = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        FlatScrollBars = True
        GridLines = True
        ParentFont = False
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
end
