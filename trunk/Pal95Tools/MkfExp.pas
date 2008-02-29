unit MkfExp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls;

type
  TfrmMKF = class(TForm)
    TreeView1: TTreeView;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListView1: TListView;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    ComboBox2: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure TreeView1Collapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
  private
    { Private declarations }
  public
    destructor Destroy; override;
    procedure PlayRles;
    procedure PlayFBP;
  end;

procedure ShowMKFs;

implementation

uses
  Main, Decoder;

{$R *.dfm}

var
  MS: TMemoryStream;
  FC: integer;

procedure ShowMKFs;
var
  frmMKF: TfrmMKF;
  i: integer;
begin
  frmMKF := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmMKF') then begin
      frmMKF := frmMain.MDIChildren[i] as TfrmMKF;
      Break;
    end;
  if frmMKF = nil then begin
    MS := TMemoryStream.Create;
    Application.CreateForm(TfrmMKF, frmMKF);
    frmMKF.ListView1.DoubleBuffered := True;
    frmMKF.ScrollBox1.DoubleBuffered := True;
    frmMKF.Panel1.DoubleBuffered := True;
//    frmRNGView.F := TMemoryStream.Create;
    frmMKF.TreeView1.Items[0].HasChildren := True;
    frmMKF.TreeView1.Items[0].Expand(False);

    frmMKF.Image1.Picture.Bitmap.FreeImage;
    frmMKF.Image1.Picture.Bitmap.PixelFormat := pf24bit;

  end;
  frmMKF.Show;
end;

destructor TfrmMKF.Destroy;
begin
  inherited Destroy;
  MS.Free;
end;

procedure TfrmMKF.PlayRles;
var
  w: word;
begin
  MS.Position := 0;
  MS.Read(w, 2);
  FC := w;

  MS.Position := w * 2 - 2;
  MS.Read(w, 2);
  if w = 0 then Dec(FC);

  Timer1Timer(Timer1);
end;

procedure TfrmMKF.PlayFBP;
var
  p: PRgbRec;
  pp: PPalRecs;
  i, j: integer;
  k: PByte;
begin
  if MS.Size <> 64000 then Exit;

  pp := Palette[ComboBox2.ItemIndex];

  Image1.Picture.Bitmap.FreeImage;
  Image1.Picture.Bitmap.Width := 320;
  Image1.Picture.Bitmap.Height := 200;
//  Image1.Picture.Bitmap.PixelFormat := pf24bit;

  k := MS.Memory;
  for j:=0 to 200-1 do begin
    p := Image1.Picture.Bitmap.ScanLine[j];
    for i:=0 to 320-1 do begin
      p^.r := pp^[k^].r shl 2;
      p^.g := pp^[k^].g shl 2;
      p^.b := pp^[k^].b shl 2;
      Inc(p);
      Inc(k);
    end;
  end;

  Image1.Invalidate;
end;

procedure TfrmMKF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
//  MS.Free;
end;

procedure TfrmMKF.TreeView1Expanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
var
  sr: TSearchRec;
  n: TTreeNode;
  f: TFileStream;
  i, j, k, l: integer;
begin
  if not Node.HasChildren or (Node.Count > 0) then Exit;

  case Node.Level of
   0: if FindFirst(PalPath + '*.MKF', faAnyFile, sr) = 0 then begin
        repeat
          n := TreeView1.Items.AddChild(Node, sr.Name);
          n.HasChildren := True;
          // stateindex equal "1" means file is compressed.
          if SameText(n.Text, 'ABC.MKF') then n.StateIndex := 1 else
          if SameText(n.Text, 'F.MKF') then n.StateIndex := 1 else
          if SameText(n.Text, 'FBP.MKF') then n.StateIndex := 1 else
          if SameText(n.Text, 'FIRE.MKF') then n.StateIndex := 1 else
          if SameText(n.Text, 'MGO.MKF') then n.StateIndex := 1 else
          if SameText(n.Text, 'MAP.MKF') then n.StateIndex := 1 else {}
            n.StateIndex := 0;

        until FindNext(sr) <> 0;
        FindClose(sr);
      end;
   1: begin
        f := TFileStream.Create(PalPath + Node.Text, fmOpenRead);
        f.Read(k, 4);  // sub file offset table size. file count equal k / 4 - 1
        f.Position := 0;
        for i:=0 to (k div 4) - 2 do begin
          f.Read(j, 4); // sub file offset
          f.Read(l, 4); // next sub file offset
          f.Position := f.Position - 4; //
          n := TreeView1.Items.AddChild(Node, Format('$%0.4X (%d) %d Bytes', [i, i, l - j]) );
          n.StateIndex := j;       // position
          n.ImageIndex := l - j;   // size
        end;
        f.Free;
//        StatusBar1.Panels[2].Text := IntToStr(Node.Count) + ' files.'
      end;
   end;
end;

procedure TfrmMKF.TreeView1Collapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
  AllowCollapse := Node.Level <> 0;
end;

procedure TfrmMKF.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  sz: integer;
begin
  ListView1.Items.Count := 0;

  Label1.Caption := 'Info: ';

  Image1.Picture.Bitmap.FreeImage;
  Image1.Picture.Bitmap.Width := 0;
  Image1.Picture.Bitmap.Height := 0;

  FC := 0;
  Timer1.Tag := 0;
  Timer1.Enabled := False;

  if (Node = nil) or (Node.Level <> 2) or (Node.ImageIndex = 0) then begin
    MS.Size := 0;

  end else begin
    DecodeStream( Node.Parent.Text, Node.Index, Node.Parent.StateIndex = 1, MS );
  end;

  if MS.Size > 0 then begin
    // update hex view
    sz := MS.Size;
    if (sz and $0000F) <> 0
      then ListView1.Items.Count := (sz div 16) + 1
      else ListView1.Items.Count := (sz div 16);

    if SameText(Node.Parent.Text, 'ABC.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'BALL.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'F.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'FIRE.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'GOP.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'MGO.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'RGM.MKF') then PlayRles else
    if SameText(Node.Parent.Text, 'DATA.MKF') and (Node.Index in [9, 10, 12]) then PlayRles else

    if SameText(Node.Parent.Text, 'FBP.MKF') then PlayFBP else
    ;

  end;

  ListView1.Invalidate;
end;

procedure TfrmMKF.ListView1Data(Sender: TObject; Item: TListItem);
var
  i, j: integer;
  a: array [0..15] of Byte;
  s1, s2: string;
begin
  if Item = nil then Exit;

  i := Item.Index;
  Item.Caption := IntToHex( i shl 4, 8 );

  MS.Position := i * 16;
  j := MS.Read(a, 16);

  s1 := '';
  s2 := '';
  for i:=0 to 15 do begin
    if i = j then Break;

    case i of
     0, 2, 4, 6, 8, 10, 12, 14: s1 := s1 + Format('%0.2X', [a[i]]);
     1, 3, 5, 9, 11, 13: s1 := s1 + Format('%0.2X ', [a[i]]);
     7:      s1 := s1 + Format('%0.2X-', [a[i]]);
     15:      s1 := s1 + Format('%0.2X', [a[i]]);
    end;

    if (a[i] >= 32) and (a[i] < 127)
      then s2 := s2 + Chr(a[i])
      else s2 := s2 + '.';
  end;

  Item.SubItems.Add(s1);
  Item.SubItems.Add(s2);
end;

procedure TfrmMKF.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  DrawRleP(MS, Timer1.Tag, Image1.Picture.Bitmap, ComboBox2.ItemIndex );
  Label1.Caption := Format('Info: %d/%d  pic: %d x %d', [Timer1.Tag + 1, FC, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height ]);
  Image1.Invalidate;

  Timer1.Tag := Timer1.Tag + 1;
  if Timer1.Tag >= FC then Timer1.Tag := 0;

  if FC > 1 then Timer1.Enabled := True;
end;

procedure TfrmMKF.Button1Click(Sender: TObject);
begin
  if FC = 0 then Exit;
  Timer1.Enabled := False;

  Timer1.Tag := Timer1.Tag - 1;
  if Timer1.Tag < 0 then Timer1.Tag := FC - 1;

  DrawRleP(MS, Timer1.Tag, Image1.Picture.Bitmap, ComboBox2.ItemIndex );
  Label1.Caption := Format('Info: %d/%d  pic: %d x %d', [Timer1.Tag + 1, FC, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height ]);
  Image1.Invalidate;

end;

procedure TfrmMKF.Button2Click(Sender: TObject);
begin
  if FC = 0 then Exit;
  Timer1.Enabled := False;

  Timer1.Tag := Timer1.Tag + 1;
  if Timer1.Tag >= FC then Timer1.Tag := 0;

  DrawRleP(MS, Timer1.Tag, Image1.Picture.Bitmap, ComboBox2.ItemIndex );
  Label1.Caption := Format('Info: %d/%d  pic: %d x %d', [Timer1.Tag + 1, FC, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height ]);
  Image1.Invalidate;
end;

procedure TfrmMKF.ComboBox2Change(Sender: TObject);
var
  b: Boolean;
begin
  if FC <> 0 then begin
    b := Timer1.Enabled;
    Timer1.Enabled := False;

    DrawRleP(MS, Timer1.Tag, Image1.Picture.Bitmap, ComboBox2.ItemIndex );
    Image1.Invalidate;

    if b then Timer1.Enabled := True;
  end else begin
    //
    if TreeView1.Selected = nil then Exit;
    if TreeView1.Selected.Level <> 2 then Exit;
    if SameText(TreeView1.Selected.Parent.Text, 'FBP.MKF') then PlayFBP;
    
  end;
end;

end.
