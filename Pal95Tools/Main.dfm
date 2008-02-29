object frmMain: TfrmMain
  Left = 81
  Top = 67
  Width = 870
  Height = 619
  Caption = 'Pal95 Tools'
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  WindowMenu = Window1
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 554
    Width = 862
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 150
      end
      item
        Text = '(C)1995-2005,OopsWare.China.'
        Width = 50
      end>
    SimplePanel = False
  end
  object MainMenu1: TMainMenu
    Left = 115
    Top = 257
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object EventIndex1: TMenuItem
        Caption = '&Event Objects ...'
        OnClick = EventIndex1Click
      end
      object StageIndex1: TMenuItem
        Caption = 'S&tages ...'
        OnClick = StageIndex1Click
      end
      object ItemIndex1: TMenuItem
        Caption = '&Items ...'
        OnClick = ItemIndex1Click
      end
      object Script1: TMenuItem
        Caption = '&Scripts ..'
        OnClick = Script1Click
      end
      object Map1: TMenuItem
        Caption = '&Map info ...'
        OnClick = Map1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Shop1: TMenuItem
        Caption = 'S&hop ...'
        OnClick = Shop1Click
      end
      object Magic1: TMenuItem
        Caption = 'M&agic ...'
        OnClick = Magic1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object MKFExplorer1: TMenuItem
        Caption = 'M&KF Explorer ...'
        OnClick = MKFExplorer1Click
      end
      object Palette1: TMenuItem
        Caption = 'Pa&lette ...'
        OnClick = Palette1Click
      end
      object RNGView1: TMenuItem
        Caption = '&RNG View ...'
        OnClick = RNGView1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object BIG51: TMenuItem
        AutoCheck = True
        Caption = '&Convert BIG5 to GBK'
        OnClick = BIG51Click
      end
    end
    object Project1: TMenuItem
      Caption = '&Project'
      object MakeJ2MEFonts1: TMenuItem
        Caption = 'Make J2ME &Fonts ...'
        OnClick = MakeJ2MEFonts1Click
      end
      object ExportBALL1: TMenuItem
        Caption = 'Export &BALL ...'
        OnClick = ExportBALL1Click
      end
      object ExportMGO1: TMenuItem
        Caption = 'Export &MGO ...'
        OnClick = ExportMGO1Click
      end
      object ExportFBP1: TMenuItem
        Caption = 'Export FB&P ...'
        OnClick = ExportFBP1Click
      end
    end
    object Window1: TMenuItem
      Caption = '&Window'
      object CloseAll1: TMenuItem
        Caption = '&Close All '
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object About1: TMenuItem
        Caption = '&About...'
      end
    end
  end
  object OpenDialog1: TOpenDialog
    FileName = 'PAL.EXE'
    Filter = 'PAL.EXE|PAL.EXE'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = #36873#25321' Pal95 '#23433#35013#36335#24452
    Left = 146
    Top = 257
  end
end
