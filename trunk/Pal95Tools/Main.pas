unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, Scriptor;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Map1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    EventIndex1: TMenuItem;
    StageIndex1: TMenuItem;
    Script1: TMenuItem;
    Window1: TMenuItem;
    CloseAll1: TMenuItem;
    ItemIndex1: TMenuItem;
    Project1: TMenuItem;
    MakeJ2MEFonts1: TMenuItem;
    ExportMGO1: TMenuItem;
    ExportBALL1: TMenuItem;
    ExportFBP1: TMenuItem;
    N1: TMenuItem;
    BIG51: TMenuItem;
    Palette1: TMenuItem;
    N2: TMenuItem;
    Shop1: TMenuItem;
    Magic1: TMenuItem;
    RNGView1: TMenuItem;
    N3: TMenuItem;
    MKFExplorer1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure Map1Click(Sender: TObject);
    procedure EventIndex1Click(Sender: TObject);
    procedure StageIndex1Click(Sender: TObject);
    procedure ItemIndex1Click(Sender: TObject);
    procedure Script1Click(Sender: TObject);
    procedure MakeJ2MEFonts1Click(Sender: TObject);
    procedure ExportMGO1Click(Sender: TObject);
    procedure ExportBALL1Click(Sender: TObject);
    procedure ExportFBP1Click(Sender: TObject);
    procedure BIG51Click(Sender: TObject);
    procedure Palette1Click(Sender: TObject);
    procedure Shop1Click(Sender: TObject);
    procedure Magic1Click(Sender: TObject);
    procedure RNGView1Click(Sender: TObject);
    procedure MKFExplorer1Click(Sender: TObject);
  private
    { Private declarations }
  public
    destructor Destroy; override;
    procedure Init;
  end;

var
  frmMain: TfrmMain;
  PalPath: string;
  PalIsDos: integer;
  scr_def: TScriptor;
  isBig5: Boolean = false;

implementation

{$R *.dfm}

uses
  IniFiles, MapInfo, Decoder, EventIndex, StageIndex, ItemIndex, Msg,
  Script, Talks, PathSel, PaletteExp, Shop, Magic, RngView, MkfExp;

procedure TfrmMain.Init;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'Pal95Tools.ini');
  PalPath := ini.ReadString('main', 'path', '');
//  SavePath := ini.ReadString('main', 'save_path', '');
  if not FileExists(PalPath + 'PAL.EXE') then begin
     if not OpenDialog1.Execute then  begin
       Application.Terminate;
       Exit;
     end;
     PalPath := ExtractFilePath(OpenDialog1.FileName);
     ini.WriteString('main', 'path', PalPath);
  end;
  if FileExists(PalPath + 'pal.ini') then begin
    StatusBar1.Panels[1].Text := '[WIN] ' + PalPath;
    PalIsDos := 0
  end else begin
    Project1.Enabled := False;
    StatusBar1.Panels[1].Text := '[DOS] ' + PalPath;
    PalIsDos := 1;
  end;


  ini.Free;

  Palette := TPalPalette.Create;
  PalMsg := TPalMessages.Create;
  scr_def := TScriptor.Create;

//  DoMapInfo(12);
//  DoMapInfo(12);
//  ShowEventIndex;
//  ShowPalette;
//  ShowMagics
//  ShowMKFs
end;

destructor TfrmMain.Destroy;
begin
  inherited Destroy;
  Palette.Free;
  PalMsg.Free;
  scr_def.Free;  
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.Map1Click(Sender: TObject);
begin
  DoMapInfo(0);
end;

procedure TfrmMain.EventIndex1Click(Sender: TObject);
begin
  ShowEventIndex
end;

procedure TfrmMain.StageIndex1Click(Sender: TObject);
begin
  ShowStageIndex
end;

procedure TfrmMain.ItemIndex1Click(Sender: TObject);
begin
  ShowItemIndex
end;

procedure TfrmMain.Script1Click(Sender: TObject);
begin
  ShowScripts(0);
end;

procedure TfrmMain.MakeJ2MEFonts1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmTalk, frmTalk);

end;

procedure TfrmMain.ExportMGO1Click(Sender: TObject);
var
  s: string;
  i: integer;
begin
  if SelectSavePath('Select Path to Export MGO Files ...', s) <> ID_OK then Exit;
  if not DirectoryExists(s) then begin
    MessageBox(Handle, 'Directory NOT Exists, 0 files export.', 'Error', MB_ICONSTOP);
    Exit;
  end;
  i := DecodeAll('MGO.MKF', s, true);
  MessageBox(Handle, PChar(IntToStr(i) + ' Files Export to:'#13#10+s), 'Done', MB_ICONINFORMATION);
end;

procedure TfrmMain.ExportBALL1Click(Sender: TObject);
var
  s: string;
  i: integer;
begin
  if SelectSavePath('Select Path to Export BALL Files ...', s) <> ID_OK then Exit;
  if not DirectoryExists(s) then begin
    MessageBox(Handle, 'Directory NOT Exists, 0 files export.', 'Error', MB_ICONSTOP);
    Exit;
  end;
  i := DecodeAll('BALL.MKF', s, false);
  MessageBox(Handle, PChar(IntToStr(i) + ' Files Export to:'#13#10+s), 'Done', MB_ICONINFORMATION);
end;

procedure TfrmMain.ExportFBP1Click(Sender: TObject);
var
  s: string;
  i: integer;
begin
  if SelectSavePath('Select Path to Export FBP Files ...', s) <> ID_OK then Exit;
  if not DirectoryExists(s) then begin
    MessageBox(Handle, 'Directory NOT Exists, 0 files export.', 'Error', MB_ICONSTOP);
    Exit;
  end;
  i := DecodeAllFBP(s);
  MessageBox(Handle, PChar(IntToStr(i) + ' Files Export to:'#13#10+s), 'Done', MB_ICONINFORMATION);
end;

procedure TfrmMain.BIG51Click(Sender: TObject);
begin
  isBig5 := BIG51.Checked;
end;

procedure TfrmMain.Palette1Click(Sender: TObject);
begin
  ShowPalette
end;

procedure TfrmMain.Shop1Click(Sender: TObject);
begin
  ShowShops
end;

procedure TfrmMain.Magic1Click(Sender: TObject);
begin
  ShowMagics;
end;

procedure TfrmMain.RNGView1Click(Sender: TObject);
begin
  ShowRNGs
end;

procedure TfrmMain.MKFExplorer1Click(Sender: TObject);
begin
  ShowMKFs
end;

end.
