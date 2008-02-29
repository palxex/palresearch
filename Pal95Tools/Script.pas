unit Script;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Buttons, StdCtrls, Menus, ClipBrd;

type
  TfrmScript = class(TForm)
    ListView1: TListView;
    Panel1: TPanel;
    Edit1: TEdit;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
  private
    { Private declarations }
  public
    SSS4: TMemoryStream;
    destructor Destroy; override;
  end;

procedure ShowScripts(jp: integer);

implementation

uses
  Main, Decoder;

{$R *.dfm}

procedure ShowScripts(jp: integer);
var
  frmScript: TfrmScript;
  i: integer;
begin
  frmScript := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmScript') then begin
      frmScript := frmMain.MDIChildren[i] as TfrmScript;
      Break;
    end;
  if frmScript = nil then begin
    Application.CreateForm(TfrmScript, frmScript);

    frmScript.SSS4 := TMemoryStream.Create;
    DecodeStream('sss.mkf', 4, False, frmScript.SSS4);

    frmScript.ListView1.Items.Count := frmScript.SSS4.Size div 8;

  end;

  frmScript.Show;
  if (jp >= 0) and (jp<frmScript.ListView1.Items.Count) then begin
//    frmScript.ListView1.ItemIndex := jp;
    frmScript.ListView1.Items[jp].Focused := True;
    frmScript.ListView1.Items[jp].Selected := True;
    frmScript.ListView1.Items[jp].MakeVisible(False);
  end;

end;

destructor TfrmScript.Destroy;
begin
  inherited Destroy;
  SSS4.Free;
end;

procedure TfrmScript.ListView1Data(Sender: TObject; Item: TListItem);
var
  eb: packed array [0..3] of Word;
  s: string;
begin
  Item.Caption := Format('$%0.4X', [Item.Index]);
  SSS4.Position := Item.Index * 8;
  SSS4.Read(eb, sizeof(eb));
  Item.SubItems.Add( Format('%0.4X %0.4X %0.4X %0.4X', [eb[0], eb[1], eb[2], eb[3]]) );
  Item.SubItems.Add( scr_def.Trans(eb[0], eb[1], eb[2], eb[3], s ) );
  Item.SubItems.Add( s );
end;

procedure TfrmScript.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmScript.SpeedButton1Click(Sender: TObject);
var
  i: integer;
begin
  i := StrToIntDef('$' + Trim(Edit1.Text), -1);
  if (i >= 0) and (i < ListView1.Items.Count) then begin
//    ListView1.ItemIndex := i;
    ListView1.Items[i].Focused := True;
    ListView1.Items[i].Selected := True;
    ListView1.Items[i].MakeVisible(False);
    ListView1.SetFocus;
  end;
end;

procedure TfrmScript.SpeedButton2Click(Sender: TObject);

  function split(var s: string): string;
  var
    i: integer;
  begin
    i := Pos(' ', s);
    if i>0 then begin
      Result := Copy(s, 1, i-1);
      Delete(s, 1, i);
      s := Trim(s);
    end else begin
      Result := s;
      s := '';
    end;
  end;

var
  s: string;
  v1, v2, v3, v4: integer;
  i, j, k: integer;
  eb: packed array [0..3] of Word;
begin
  s := Trim(Edit1.Text);

  v1 := StrToIntDef('$' + split(s), -1);
  v2 := StrToIntDef('$' + split(s), -1);
  v3 := StrToIntDef('$' + split(s), -1);
  v4 := StrToIntDef('$' + split(s), -1);

  if (v1 = -1) and (v2 = -1) and (v3 = -1) and (v4 = -1) then Exit;

  j := ListView1.ItemFocused.Index;
  for i:=0 to ListView1.Items.Count-1 do begin
    SSS4.Position := ((j + 1 + i) mod ListView1.Items.Count) * 8;
    SSS4.Read(eb, sizeof(eb));
    if ((v1 = -1) or (v1 = eb[0])) and
       ((v2 = -1) or (v2 = eb[1])) and
       ((v3 = -1) or (v3 = eb[2])) and
       ((v4 = -1) or (v4 = eb[3])) then begin

      k := (j + 1 + i) mod ListView1.Items.Count;
      ListView1.Items[k].Focused := True;
      ListView1.Items[k].Selected := True;
      ListView1.Items[k].MakeVisible(False);
      ListView1.SetFocus;

      Exit;
    end;
  end;
end;

procedure TfrmScript.Copy1Click(Sender: TObject);
var
  eb: packed array [0..3] of Word;
  s, tmp: string;
  item: TListItem;
begin // copy to clipboard
  item := ListView1.Selected;
  s := '';
  while item <> nil do begin
    SSS4.Position := item.Index * 8;
    SSS4.Read(eb, sizeof(eb));
    s := s + Format('@%0.4X: %0.4X %0.4X %0.4X %0.4X : %s'#13#10, [item.Index, eb[0], eb[1], eb[2], eb[3], scr_def.Trans(eb[0], eb[1], eb[2], eb[3], tmp )]);
    item := ListView1.GetNextItem(item, sdAll, [isSelected]);
  end;
  Clipboard.SetTextBuf(Pchar(s));
end;

end.
