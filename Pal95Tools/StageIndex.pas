unit StageIndex;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus;

type
  TfrmStageIndex = class(TForm)
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    GotoMap1: TMenuItem;
    GotoEnterScript1: TMenuItem;
    GotoExitScript1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure GotoMap1Click(Sender: TObject);
    procedure GotoEnterScript1Click(Sender: TObject);
    procedure GotoExitScript1Click(Sender: TObject);
  private
    { Private declarations }
  public
    SSS2: TMemoryStream;
    destructor Destroy; override;
  end;

procedure ShowStageIndex;

implementation

uses
  Main, Decoder, MapInfo, Script;

{$R *.dfm}

procedure ShowStageIndex;
var
  frmStageIndex: TfrmStageIndex;
  i: integer;
begin
  frmStageIndex := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmStageIndex') then begin
      frmStageIndex := frmMain.MDIChildren[i] as TfrmStageIndex;
      Break;
    end;
  if frmStageIndex = nil then begin
    Application.CreateForm(TfrmStageIndex, frmStageIndex);

    frmStageIndex.SSS2 := TMemoryStream.Create;
    DecodeStream('sss.mkf', 1, False, frmStageIndex.SSS2);

    frmStageIndex.ListView1.Items.Count := frmStageIndex.SSS2.Size div 8;

  end;
  frmStageIndex.Show;
end;

destructor TfrmStageIndex.Destroy;
begin
  inherited Destroy;
  SSS2.Free;
end;

procedure TfrmStageIndex.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmStageIndex.ListView1Data(Sender: TObject; Item: TListItem);
var
  eb: packed array [0..3] of Word;
begin
  Item.Caption := Format('$%0.4X #%d', [Item.Index+1, Item.Index+1]);
  SSS2.Position := Item.Index * 8;
  SSS2.Read(eb, sizeof(eb));
  Item.SubItems.Add ( Format('Map:%3d,  Script:$%0.4x, $%0.4x, $%0.4x', [eb[0], eb[1], eb[2], eb[3] ] ) );
  Item.SubItems.Add (Format('%0.4X %0.4X %0.4X %0.4X', [eb[0], eb[1], eb[2], eb[3] ] ) );
end;

procedure TfrmStageIndex.GotoMap1Click(Sender: TObject);
var
  eb: packed array [0..3] of Word;
begin
  if ListView1.Selected = nil then Exit;
  SSS2.Position := ListView1.Selected.Index * 8;
  SSS2.Read(eb, sizeof(eb));
  DoMapInfo( eb[0] );
end;

procedure TfrmStageIndex.GotoEnterScript1Click(Sender: TObject);
var
  eb: packed array [0..3] of Word;
begin
  if ListView1.Selected = nil then Exit;
  SSS2.Position := ListView1.Selected.Index * 8;
  SSS2.Read(eb, sizeof(eb));
  ShowScripts(eb[1]);

end;

procedure TfrmStageIndex.GotoExitScript1Click(Sender: TObject);
var
  eb: packed array [0..3] of Word;
begin
  if ListView1.Selected = nil then Exit;
  SSS2.Position := ListView1.Selected.Index * 8;
  SSS2.Read(eb, sizeof(eb));
  ShowScripts(eb[2]);
end;

end.
