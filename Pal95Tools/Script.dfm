object frmScript: TfrmScript
  Left = 176
  Top = 154
  Width = 686
  Height = 435
  Caption = 'Script SSS #4'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefaultPosOnly
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 32
    Width = 678
    Height = 376
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 44
      end
      item
        Caption = 'Data'
        Width = 128
      end
      item
        Caption = 'Trans'
        Width = 280
      end
      item
        Caption = 'Desc'
        Width = 200
      end>
    HideSelection = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 678
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 5
      Top = 9
      Width = 41
      Height = 13
      Caption = 'Script ID'
    end
    object SpeedButton1: TSpeedButton
      Left = 147
      Top = 6
      Width = 70
      Height = 22
      Caption = 'Goto Script'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 219
      Top = 6
      Width = 86
      Height = 22
      Caption = 'Data Search'
      OnClick = SpeedButton2Click
    end
    object Edit1: TEdit
      Left = 50
      Top = 6
      Width = 93
      Height = 21
      TabOrder = 0
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 205
    Top = 136
    object Copy1: TMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = Copy1Click
    end
  end
end
