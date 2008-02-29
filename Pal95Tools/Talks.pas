unit Talks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmTalk = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CalcTextFile(fn: string);
  end;

var
  frmTalk: TfrmTalk;

implementation

uses
  Main;

{$R *.dfm}

var
  wucnt: array [0..93, 0..93] of integer;
  aucnt: array [0..255] of integer;

procedure TfrmTalk.CalcTextFile(fn: string);
var
  msg: TMemoryStream;
  b1, b2: Byte;
begin
  msg := TMemoryStream.Create;
  msg.LoadFromFile(fn);
  while msg.Read(b1, 1) = 1 do begin
    if b1 > $a0 then begin
      msg.Read(b2, 1);

      Dec(b1, $A1);
      Dec(b2, $A1);

      Inc(wucnt[b1, b2]);

    end else begin
       // ascii
       Inc(aucnt[b1]);
    end;
  end;
end;

procedure TfrmTalk.Button1Click(Sender: TObject);
var
  i, j: integer;
  ss: TStrings;
  buf: array [0..2] of char;
begin
  //
  FillChar(wucnt, sizeof(wucnt), 0);
  FillChar(aucnt, sizeof(aucnt), 0);
  CalcTextFile(PalPath + 'M.MSG');
  CalcTextFile(PalPath + 'WORD.DAT');

//  OopsHexEditor1.EditBuffer( @aucnt, sizeof(aucnt) );

  ss := TStringList.Create;

  for i:=0 to 255 do begin
    if aucnt[i] <> 0 then begin
      ss.Add( '"' + Chr(i) + '": 0x' + IntToHex(i, 2) + '  ' + IntToStr(aucnt[i]) );
    end;
  end;

  ss.add('---------');

  buf[2] := #0;
  for j:=0 to 93 do
    for i:=0 to 93 do
      if  wucnt[j, i] > 0 then begin
        buf[0] := chr(j+$A1);
        buf[1] := chr(i+$A1);
        ss.Add( Format('"%s" 0x%0.2x%0.2x %d', [buf, j+$A1, i+$A1, wucnt[j, i] ] )  );
      end;
//  ss.SaveToFile('W.TXT');
  Memo1.Lines.Assign(ss);
  ss.Free; {}

end;

procedure TfrmTalk.Button2Click(Sender: TObject);
var
  q, w: integer;
  fnt: TMemoryStream;
  z: byte;

  i, j: integer;
  p: PByte;
  b: byte;
begin
  if Length(Edit1.Text)<2 then Exit;
  q := Ord(Edit1.Text[1]);
  w := Ord(Edit1.Text[2]);

  Label1.Caption := Format( '0x%0.2x%0.2x', [q, w] );

  Image1.Picture.Bitmap.Width := 16;
  Image1.Picture.Bitmap.Height := 16;
  Image1.Picture.Bitmap.PixelFormat := pf24bit;

  q := q - $0A1;
  w := w - $0A1;

  fnt := TMemoryStream.Create;
  fnt.LoadFromFile('HZK16');

  fnt.Position := (q * 94 + w) * 32;
  for j:=0 to 15 do begin
    p := Image1.Picture.Bitmap.ScanLine[j];
    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

  end;

  fnt.Free;

  Image1.Invalidate;
end;

procedure horiHZK16;
var
  fi, fo: TMemoryStream;
  bi: array [0..31] of Byte;
  bo: array [0..29] of Byte;
  i, j: integer;
  bb: array [0..15, 0..15] of Byte;
  z: byte;
begin
  fi := TMemoryStream.Create;
  fi.LoadFromFile('HZK16');

  fo := TMemoryStream.Create;
  fo.Size := (fi.Size div 32) * 30;

  while fi.Read(bi, 32) = 32 do begin

    for j:=0 to 15 do begin
      z := bi[j*2];
      for i:=0 to 7 do begin
        if (z and $80) = 0
          then bb[j, i] := 0
          else bb[j, i] := 1;
        z := z shl 1;
      end;
      z := bi[j*2+1];
      for i:=8 to 15 do begin
        if (z and $80) = 0
          then bb[j, i] := 0
          else bb[j, i] := 1;
        z := z shl 1;
      end;
    end;

    FillChar(bo, sizeof(bo), 0);
    for i:=14 downto 0 do begin
      for j:=0 to 7 do
        if bb[j, i] <> 0 then
           bo[(14-i)*2] := bo[(14-i)*2] or ( 1 shl (7-j) );
      for j:=8 to 15 do
        if bb[j, i] <> 0 then
           bo[(14-i)*2+1] := bo[(14-i)*2+1] or ( 1 shl (15-j) );
    end;


    fo.Write(bo, 30);
  end;

  fi.Free;
  fo.SaveToFile('HZK16x15h');
  fo.Free;
end;

procedure horiASC16;
var
  fi, fo: TMemoryStream;
  bi: array [0..15] of Byte;
  bo: array [0..15] of Byte;
  i, j: integer;
  bb: array [0..15, 0..7] of Byte;
  z: byte;
begin
  fi := TMemoryStream.Create;
  fi.LoadFromFile('ASC16');

  fo := TMemoryStream.Create;
  fo.Size := fi.Size;

  while fi.Read(bi, 16) = 16 do begin

    for j:=0 to 15 do begin
      z := bi[j];
      for i:=0 to 7 do begin
        if (z and $80) = 0
          then bb[j, i] := 0
          else bb[j, i] := 1;
        z := z shl 1;
      end;
    end;

    FillChar(bo, sizeof(bo), 0);
    for i:=7 downto 0 do begin
      for j:=0 to 7 do
        if bb[j, i] <> 0 then
           bo[(7-i)*2] := bo[(7-i)*2] or ( 1 shl (7-j) );
      for j:=8 to 15 do
        if bb[j, i] <> 0 then
           bo[(7-i)*2+1] := bo[(7-i)*2+1] or ( 1 shl (15-j) );
    end;

    fo.Write(bo, 16);
  end;

  fi.Free;
  fo.SaveToFile('ASC16x8h');
  fo.Free;


end;

procedure TfrmTalk.Button3Click(Sender: TObject);
begin
  horiHZK16;
  horiASC16;
end;

procedure TfrmTalk.Button4Click(Sender: TObject);
var
  q, w: integer;
  fnt: TMemoryStream;
  z: byte;

  i, j: integer;
  p: PByte;
  b: byte;
begin
  if Length(Edit1.Text)<2 then Exit;
  q := Ord(Edit1.Text[1]);
  w := Ord(Edit1.Text[2]);

  Label1.Caption := Format( '0x%0.2x%0.2x', [q, w] );

  Image1.Picture.Bitmap.Width := 16;
  Image1.Picture.Bitmap.Height := 16;
  Image1.Picture.Bitmap.PixelFormat := pf24bit;

  q := q - $0A1;
  w := w - $0A1;

  fnt := TMemoryStream.Create;
  fnt.LoadFromFile('HZK16x15h');

  fnt.Position := (q * 94 + w) * 30;
  for j:=0 to 14 do begin
    p := Image1.Picture.Bitmap.ScanLine[j];
    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

  end;

  fnt.Free;

  Image1.Invalidate;
end;

procedure TfrmTalk.Button5Click(Sender: TObject);
var
  v, i, j: integer;
  fnt: TMemoryStream;
  p: PByte;
  b, z: Byte;

begin
  v := StrToIntDef( Edit1.text, -1 );
  if (v < 0) or (v>255) then Exit;

  fnt := TMemoryStream.Create;
  fnt.LoadFromFile('ASC16x8h');

  Image1.Picture.Bitmap.Width := 16;
  Image1.Picture.Bitmap.Height := 16;
  Image1.Picture.Bitmap.PixelFormat := pf24bit;

  fnt.Position := v * 16;

  for j:=0 to 7 do begin
    p := Image1.Picture.Bitmap.ScanLine[j];
    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

    fnt.Read(z, 1);
    for i:=0 to 7 do begin
      if (z and $80) = 0
        then b := $FF
        else b := $0;
      z := z shl 1;

      p^ := b; Inc(p);
      p^ := b; Inc(p);
      p^ := b; Inc(p);
    end;

  end;
  
  Image1.Invalidate;

  fnt.Free;
end;

procedure TfrmTalk.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree
end;

procedure TfrmTalk.Button6Click(Sender: TObject);
var
  fo: TMemoryStream;
  fo2: TMemoryStream;
  fi: TMemoryStream;
  i, j: integer;
  w, k: Word;
  buf: array [0..29] of Byte;
begin
  // built HZ used table
  FillChar(aucnt, sizeof(aucnt), 0);
  FillChar(wucnt, sizeof(wucnt), 0);
  CalcTextFile(PalPath + 'M.MSG');
  CalcTextFile(PalPath + 'WORD.DAT');

  fo := TMemoryStream.Create;
  fo2 := TMemoryStream.Create;

  fi := TMemoryStream.Create;
  fi.LoadFromFile('ASC16x8h');

  // copy ASCII 0x00~0x7F Only
  fo.CopyFrom(fi, 2048);

  fi.Size := 0;
  fi.LoadFromFile('HZK16x15h');

  w := 0;
  k := 0;
  for j:=0 to 93 do
    for i:=0 to 93 do begin
      fi.Read(buf, 30);
      if wucnt[j, i] <> 0 then begin
        fo.Write(buf, 30);
        fo2.Write(w, 2);
        w := w + 1;
      end else
        fo2.Write(k, 2);
    end;

  fo.SaveToFile('PalHZK');
  fo2.SaveToFile('PalHZI');

  fo.Free;
  fo2.Free;
  fi.Free;
end;

end.
