unit RngView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmRNGView = class(TForm)
    Label1: TLabel;
    ComboBox1: TComboBox;
    Image1: TImage;
    Timer1: TTimer;
    ComboBox2: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    F: TMemoryStream;
    FC: integer;
  end;

procedure ShowRNGs;

implementation

uses Main, Decoder;

{$R *.dfm}

var
  old: packed array [0..199, 0..319] of Byte;

procedure ShowRNGs;
var
  frmRNGView: TfrmRNGView;
  i: integer;
begin
  frmRNGView := nil;
  for i:=0 to frmMain.MDIChildCount-1 do
    if SameText(frmMain.MDIChildren[i].ClassName, 'TfrmRNGView') then begin
      frmRNGView := frmMain.MDIChildren[i] as TfrmRNGView;
      Break;
    end;
  if frmRNGView = nil then begin
    Application.CreateForm(TfrmRNGView, frmRNGView);
    frmRNGView.DoubleBuffered := True;
    frmRNGView.F := TMemoryStream.Create;

    frmRNGView.Image1.Picture.Bitmap.Width := frmRNGView.Image1.Width;
    frmRNGView.Image1.Picture.Bitmap.Height := frmRNGView.Image1.Height;
    frmRNGView.Image1.Picture.Bitmap.PixelFormat := pf24bit;


    for i:=0 to MKFFileCount('RNG')-1 do
      frmRNGView.ComboBox1.Items.Add( Format( '%0.2X# - %d', [i, i] ) );
    frmRNGView.ComboBox1.ItemIndex := 0;
    frmRNGView.ComboBox1Change(frmRNGView.ComboBox1);
  end;
  frmRNGView.Show;
end;

procedure TfrmRNGView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  Action := caFree;
  F.Free;
end;

procedure TfrmRNGView.ComboBox1Change(Sender: TObject);
var
  i: integer;
begin
  Timer1.Enabled := False;
  Timer1.Tag := 0;
  DecodeStream('RNG.MKF', ComboBox1.ItemIndex, False, F);
  F.Position := 0;
  F.Read(i, 4);
  FC := (i div 4) - 1;
//  Timer1Timer(Timer1);
  Timer1.Enabled := True;
end;

procedure DecodeRng(src: TMemoryStream; dest: PByte);
var
  dst_ptr: integer;
  p: Pointer;
  data: Byte;
  wdata, rep: Word;
  i, j: integer;
begin
  src.Position := 0;
  dst_ptr := 0;
  while true do begin
    src.Read(data, 1);
    case data of
      $00, $13: Exit;
      $01, $05: ;
      $02: Inc(dst_ptr, 2);
      $03: begin
             src.Read(data, 1);
             j := data;
             Inc(dst_ptr, (j + 1) shl 1);
           end;
      $04: begin
             src.Read(wdata, 2);
             j := wdata;
             Inc(dst_ptr, (j + 1) shl 1);
           end;
      $06: begin
             p := dest;
             Inc(pByte(p), dst_ptr);
             src.Read( pByte(p)^, 2 );
             Inc(dst_ptr, 2);
           end;
      $07: begin
             p := dest;
             Inc(pByte(p), dst_ptr);
             src.Read( pByte(p)^, 4 );
             Inc(dst_ptr, 4);
           end;
      $08: begin
             p := dest;
             Inc(pByte(p), dst_ptr);
             src.Read( pByte(p)^, 6 );
             Inc(dst_ptr, 6);
           end;
      $09: begin
             p := dest;
             Inc(pByte(p), dst_ptr);
             src.Read( pByte(p)^, 8 );
             Inc(dst_ptr, 8);
           end;
      $0A: begin
             p := dest;
             Inc(pByte(p), dst_ptr);
             src.Read( pByte(p)^, 10 );
             Inc(dst_ptr, 10);
           end;
      $0B: begin
             src.Read(data, 1);
             p := dest;
             Inc(pByte(p), dst_ptr);
             j := data;
             src.Read( pByte(p)^, (j + 1) shl 1 );
             Inc(dst_ptr, (j + 1) shl 1);
           end;
      $0C: begin
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             j := wdata;
             src.Read( pByte(p)^, (j + 1) shl 1 );
             Inc(dst_ptr, (j + 1) shl 1);
           end;
      $0D: begin
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); // Inc(pWord(p));
           end;
      $0E: begin
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); // Inc(pWord(p));
           end;
      $0F: begin
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); // Inc(pWord(p));
           end;
      $10: begin
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             pWord(p)^ := wdata; Inc(dst_ptr, 2); // Inc(pWord(p));
           end;
      $11: begin
             src.Read(data, 1);
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             for i:=0 to data do  begin
               pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             end;
           end;
      $12: begin
             src.Read(rep, 2);
             src.Read(wdata, 2);
             p := dest;
             Inc(pByte(p), dst_ptr);
             for i:=0 to rep do begin
               pWord(p)^ := wdata; Inc(dst_ptr, 2); Inc(pByte(p), 2);
             end;
           end;
    end;
  end;

end;

procedure TfrmRNGView.Timer1Timer(Sender: TObject);
var
  dst: TMemoryStream;
  i, j: integer;
  pr: PRgbRec;
  pp: PPalRecs;
begin
  Timer1.Enabled := False;
  Caption := Format('RNG View - (%d/%d)', [Timer1.Tag + 1, FC]);
  dst := TMemoryStream.Create;
  DecodeSubFile(F, Timer1.Tag, dst, True);

  if dst.Size > 4 then DecodeRng(dst, @old);

  pp := Palette[ComboBox2.itemindex];

  for j:=0 to 199 do begin
    pr := Image1.Picture.Bitmap.ScanLine[j];
    for i:=0 to 319 do begin
      pr^.r := pp^[old[j, i]].r shl 2;
      pr^.g := pp^[old[j, i]].g shl 2;
      pr^.b := pp^[old[j, i]].b shl 2;
      Inc(pr);
    end;
  end;

  Image1.Invalidate;

  dst.Free;

  Timer1.Tag := Timer1.Tag + 1;
  if Timer1.Tag < FC then begin
    Timer1.Enabled := True;
  end;
end;

end.
