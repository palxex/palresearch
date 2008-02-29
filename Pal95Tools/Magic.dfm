object frmMagic: TfrmMagic
  Left = 211
  Top = 166
  Caption = 'Magic  DATA#4'
  ClientHeight = 312
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 618
    Height = 312
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        Width = 60
      end
      item
        Caption = 'Name'
        Width = 60
      end
      item
        Caption = 'Magic Prop'
        Width = 120
      end
      item
        Caption = '??,Speed,Loop,Delay, ??,Vb,??'
        Width = 140
      end
      item
        Caption = 'MP, Dy,  Enl, Eff'
        Width = 150
      end>
    HideSelection = False
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
  end
end
