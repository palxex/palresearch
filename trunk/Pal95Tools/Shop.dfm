object frmShop: TfrmShop
  Left = 202
  Top = 163
  Width = 691
  Height = 361
  Caption = 'Shop DATA#0'
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
    Top = 0
    Width = 683
    Height = 334
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 56
      end
      item
        Caption = 'Shop info'
        Width = 600
      end>
    HideSelection = False
    OwnerData = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
  end
end
