unit Decoder;

interface

uses
  windows, Classes, SysUtils, Graphics;

type
  TPalRec = packed record
    r, g, b: Byte;
  end;
  TPalRecs = packed array [0..255] of TPalRec;
  PPalRecs = ^TPalRecs;

  TRgbRec = packed record
    b, g, r: Byte;
  end;
  PRgbRec = ^TRgbRec;

  TPalPalette = class
  private
    FBuffer: TMemoryStream;
    FPatCount: integer;
    function Get(index: integer): PPalRecs;
  public
    constructor Create;
    destructor Destroy; override;
    function Pal0Color(index: byte): integer;
    property Pal[index: integer]: PPalRecs read Get; default;
  end;

function DecodeJY(src, dst: PByte; isdos: integer): integer; cdecl;
function MKFFileCount(mkf: string): integer;
function DecodeSubFile(f: TStream; index: integer; dst: TMemoryStream; DecodeIt: Boolean ): integer;
procedure DecodeMap(mid: integer; MapStream, GopStream: TMemoryStream);
procedure DecodeStream(mkf: string; index: integer; doDecode: boolean; DestStream: TMemoryStream);
function DecodeAll(mkf: string; topath: string; doDecode: boolean): integer;

function DecodeAllFBP(topath: string): integer;

procedure DrawRle(RleStream: TMemoryStream; index: integer; Bmp: TBitmap; X, Y: integer; fixsize: Boolean = false);
procedure DrawRleP(RleStream: TMemoryStream; index: integer; Bmp: TBitmap; plt: integer);

procedure DrawBall(RleStream: TMemoryStream; index: integer; Bmp: TBitmap);
procedure Draw(mkf:string; index: integer; Bmp: TBitmap);
procedure DrawMGO(index: integer; Bmp: TBitmap);

var
  Palette: TPalPalette;

implementation

uses
  Main, pngimage;

{$WARN SYMBOL_PLATFORM OFF}
function _DecodeJY(src, dst: PByte; isdos: integer): integer; cdecl; external 'DecodeJY1.dll' index 1;
{$WARN SYMBOL_PLATFORM ON}

function DecodeJY(src, dst: PByte; isdos: integer): integer; cdecl;
begin
  Result := _DecodeJY(src, dst, PalIsDos);
end;

function MKFFileCount(mkf: string): integer;
var
  f: TFileStream;
  k: integer;
begin
  f := TFileStream.Create(PalPath + mkf + '.mkf', fmOpenRead);
  f.Position := 0;
  f.Read(k, 4);
  Result := (k div 4) - 1;
  f.Free;
end;

function DecodeSubFile(f: TStream; index: integer; dst: TMemoryStream; DecodeIt: Boolean ): integer;
var
  b, e: integer;
  tmp: TMemoryStream;
  pn: PLongword;
begin
  Result := 0;
  dst.Size := 0;
  f.Position := index * 4;
  f.Read(b, 4);
  f.Read(e, 4);
  if ( e - b ) <= 0 then Exit;

  if DecodeIt then begin
    tmp := TMemoryStream.Create;
    tmp.Size := e - b;
    tmp.Position := 0;
    f.Position := b;
    tmp.CopyFrom(f, e - b);
    pn := tmp.Memory; //    u := PLongword( tmp.Memory )^;
    if pn^ = $315F4A59 then Inc(pn);
    dst.Size := pn^;
    DecodeJY( tmp.Memory, dst.Memory, 0 );
    tmp.Free;
  end else begin
    dst.Size := e - b;
    dst.Position := 0;
    f.Position := b;
    dst.CopyFrom(f, e - b);
  end;
  Result := dst.Size;
end;

procedure DecodeMap(mid: integer; MapStream, GopStream: TMemoryStream);
var
  f: TFileStream;
begin
  f := TFileStream.Create(PalPath + 'map.mkf', fmOpenRead);
  DecodeSubFile(f, mid, MapStream, True);
  f.Free;
  f := TFileStream.Create(PalPath + 'gop.mkf', fmOpenRead);
  DecodeSubFile(f, mid, GopStream, False);
  f.Free;
end;

procedure DecodeStream(mkf: string; index: integer; doDecode: boolean; DestStream: TMemoryStream);
var
  f: TFileStream;
begin
  f := TFileStream.Create(PalPath + mkf, fmOpenRead);
  DecodeSubFile(f, index, DestStream, doDecode);
  f.Free;
end;

function DecodeAll(mkf: string; topath: string; doDecode: boolean): integer;
var
  f: TFileStream;
  i, k: integer;
  df: TMemoryStream;
begin
  f := TFileStream.Create(PalPath + mkf, fmOpenRead);
  f.Position := 0;
  f.Read(k, 4);
  k := (k div 4) - 1;

  Result := 0;
  for i:=0 to k-1 do begin
    df := TMemoryStream.Create;
    DecodeSubFile(f, i, df, doDecode);
    if df.Size > 0 then begin
      Inc(Result);
      df.SaveToFile(topath + IntToStr(i));
    end;
    df.Free;
  end;
  f.Free;
end;

procedure FbpToPngData(f: TMemoryStream; fn: string);
var
  pp: PPalRecs;
  bmp: TBitmap;

  hPal: THandle;
  pPal: PLogPalette;
  i, j: integer;
  psrc, pdst: pbyte;
  zb: byte;
// uzb: integer;
  png: TPngObject;

  tmp, tmp2: TMemoryStream;
begin

    bmp := TBitmap.Create;
    bmp.Width := 200;
    bmp.Height := 320;
    bmp.PixelFormat := pf8bit;
    pp := Palette[0];
    pPal := AllocMem(4 + 256 * 4);
    pPal^.palVersion := $300;
    pPal^.palNumEntries := 256;

    for i:=0 to 255 do begin
      pPal^.palPalEntry[i].peRed := pp^[i].r shl 2;
      pPal^.palPalEntry[i].peGreen := pp^[i].g shl 2;
      pPal^.palPalEntry[i].peBlue := pp^[i].b shl 2;
//      pPal^.palPalEntry[i].peFlags :=
    end;
    hPal := CreatePalette(pPal^);
    bmp.Palette := hPal;
    FreeMem(pPal);

//    uzb := 0;
    zb := 255;

    for j:=0 to 320-1 do begin
      pdst := bmp.ScanLine[j];
      for i:=0 to 200-1 do begin
        psrc := f.Memory;
        Inc(psrc, i*320+319-j );
        pdst^ := psrc^;
//        if psrc^ = zb then Inc(uzb);
        Inc(pdst);
      end;
    end;

    png := TPngObject.Create;
    png.Assign(bmp);
    png.TransparentColor := (pp^[zb].b shl 18) or (pp^[zb].g shl 10) or (pp^[zb].r shl 2);

    tmp := TMemoryStream.Create;
    png.CompressionLevel := 9;
    png.SaveToStream(tmp);
    png.Free;
    DeleteObject(hPal);
    bmp.Free;

 //  tmp.SaveToFile(fn + '.png');

    tmp2 := TMemoryStream.Create;
    tmp2.Size := tmp.size - 8 - 12 - 1048;

    tmp.Position := 8;
    tmp2.Position := 0;
    tmp2.CopyFrom(tmp, 25); // header
    tmp.Position := 8 + 25 + 1048;
    tmp2.CopyFrom(tmp, tmp2.Size - 25); // data
    tmp.Free;
    tmp2.SaveToFile(fn);
    tmp2.Free;
end;

function DecodeAllFBP(topath: string): integer;
var
  f: TFileStream;
  i, k: integer;
  df: TMemoryStream;
begin
  f := TFileStream.Create(PalPath + 'FBP.MKF', fmOpenRead);
  f.Position := 0;
  f.Read(k, 4);
  k := (k div 4) - 1;

  Result := 0;
  for i:=0 to k-1 do begin
    df := TMemoryStream.Create;
    DecodeSubFile(f, i, df, true);
    if df.Size > 0 then begin
      Inc(Result);
      FbpToPngData(df, topath + IntToStr(i));
    end;
    df.Free;
  end;
  f.Free;
end;

procedure DrawRle(RleStream: TMemoryStream; index: integer; Bmp: TBitmap; X, Y: integer; fixsize: Boolean = false);
var
  offset, w, h, flag: Word;
  i, j, line: integer;
  p: PByte;
  num, k: Byte;
  b: Boolean;
  cl: integer;
begin
  RleStream.Position := index * 2;
  RleStream.Read(offset, 2);
  RleStream.Position := offset shl 1; // x2
  RleStream.Read(w, 2);
  RleStream.Read(h, 2);

  if fixsize then begin
    Bmp.Width := w;
    Bmp.Height := h;
  end;

  line := 0;
  while line < h do begin
    flag := w;
    p := bmp.ScanLine[line + Y];
    Inc(p, X * 3);
    while flag > 0 do begin //处理每行的数据
      RleStream.Read(num, 1); //num := data[offset] & 0xff; //
      b := False;
      if num > $80 then begin //检查是否是透明像素
        num := num - $80;
        for i := 0 to num-1 do begin
          Dec(flag);
          // 穿透色
          Inc(p, 3);
        end;
        if num = $7F then continue; // very special case!
        b := True;
      end;
      if flag = 0 then break; //完成一行
      if b then RleStream.Read(num, 1); // 取得不透明颜色的个数
      for j := 0 to num-1 do begin
        RleStream.Read(k, 1);
        cl := Palette.Pal0Color(k);
        p^ := ((cl shr 16) and $FF); Inc(p);
        p^ := ((cl shr 8) and $FF); Inc(p);
        p^ := (cl and $FF); Inc(p);
      end;
      Dec(flag, num); //将宽度减少num
    end;
    Inc(line);
  end;

end;

procedure DrawRleP(RleStream: TMemoryStream; index: integer; Bmp: TBitmap; plt: integer);
var
  offset, w, h, flag: Word;
  i, j, line: integer;
  p: PByte;
  num, k: Byte;
  b: Boolean;

  pp: PPalRecs;
begin
  RleStream.Position := index * 2;
  RleStream.Read(offset, 2);

  Bmp.FreeImage;
  Bmp.Width := 0;
  Bmp.Height := 0;

  if (offset = 0) or ((offset * 2) >= RleStream.Size)  then Exit;

  RleStream.Position := offset shl 1; // x2
  pp := Palette[plt];

  RleStream.Read(w, 2);
  RleStream.Read(h, 2);

  Bmp.Width := w;
  Bmp.Height := h;

  line := 0;
  while line < h do begin
    flag := w;
    p := bmp.ScanLine[line];
    while flag > 0 do begin //处理每行的数据
      RleStream.Read(num, 1); //num := data[offset] & 0xff; //
      b := False;
      if num > $80 then begin //检查是否是透明像素
        num := num - $80;
        for i := 0 to num-1 do begin
          Dec(flag);
          // 穿透色
          Inc(p, 3);
        end;
        if num = $7F then continue; // very special case!
        b := True;
      end;
      if flag = 0 then break; //完成一行
      if b then RleStream.Read(num, 1); // 取得不透明颜色的个数
      for j := 0 to num-1 do begin
        RleStream.Read(k, 1);
        p^ := pp^[k].b shl 2; Inc(p);
        p^ := pp^[k].g shl 2; Inc(p);
        p^ := pp^[k].r shl 2; Inc(p);
      end;
      Dec(flag, num); //将宽度减少num
    end;
    Inc(line);
  end;
end;

procedure DrawBall(RleStream: TMemoryStream; index: integer; Bmp: TBitmap);
var
  bg, ed : integer;
  w, h, flag: Word;
  i, j, line: integer;
  p: PByte;
  num, k: Byte;
  b: Boolean;
  cl: integer;
begin
  Bmp.FreeImage;
  Bmp.Width := 1;
  Bmp.Height := 1;

  RleStream.Position := 0;
  RleStream.Read(bg, 4);
  bg := (bg div 4) - 1;
  if index >= bg then Exit;

  RleStream.Position := index * 4;
  RleStream.Read(bg, 4);
  RleStream.Read(ed, 4);

  if ( ed - bg ) <= 0 then Exit;

  RleStream.Position := bg;
  RleStream.Read(ed, 4);
  RleStream.Read(w, 2);
  RleStream.Read(h, 2);

  Bmp.FreeImage;
  Bmp.Width := w;
  Bmp.Height := h;
  Bmp.PixelFormat := pf24bit;


  line := 0;
  while line < h do begin
    flag := w;
    p := bmp.ScanLine[line];
    while flag > 0 do begin //处理每行的数据
      RleStream.Read(num, 1); //num := data[offset] & 0xff; //
      b := False;
      if num > $80 then begin //检查是否是透明像素
        num := num - $80;
        for i := 0 to num-1 do begin
          Dec(flag);
          // 穿透色
          Inc(p, 3);
        end;
        if num = $7F then continue; // very special case!
        b := True;
      end;
      if flag = 0 then break; //完成一行
      if b then RleStream.Read(num, 1); // 取得不透明颜色的个数
      for j := 0 to num-1 do begin
        RleStream.Read(k, 1);
        cl := Palette.Pal0Color(k);
        p^ := ((cl shr 16) and $FF); Inc(p);
        p^ := ((cl shr 8) and $FF); Inc(p);
        p^ := (cl and $FF); Inc(p);
      end;
      Dec(flag, num); //将宽度减少num
    end;
    Inc(line);
  end;

end;

procedure Draw(mkf:string; index: integer; Bmp: TBitmap);
var
  RleStr: TMemoryStream;
begin
  Bmp.FreeImage;
  Bmp.Width := 1;
  Bmp.Height := 1;
  Bmp.PixelFormat := pf24bit;

  RleStr := TMemoryStream.Create;
  DecodeStream(mkf, index, true, RleStr);

  if (RleStr.Size < 4) then begin
    RleStr.Free;
    Exit;
  end;

  Bmp.FreeImage;
  Bmp.Width := 320;
  Bmp.Height := 240;
  Bmp.PixelFormat := pf24bit;

  DrawRle(RleStr, 0, Bmp, 0, 0, true);

  RleStr.Free;
end;

procedure DrawMGO(index: integer; Bmp: TBitmap);
var
  RleStr: TMemoryStream;
begin
  Bmp.FreeImage;
  Bmp.Width := 1;
  Bmp.Height := 1;
  Bmp.PixelFormat := pf24bit;

  RleStr := TMemoryStream.Create;
  DecodeStream('MGO.MKF', index, true, RleStr);

  if (RleStr.Size < 4) then begin
    RleStr.Free;
    Exit;
  end;

  Bmp.FreeImage;
  Bmp.Width := 320;
  Bmp.Height := 240;
  Bmp.PixelFormat := pf24bit;

  DrawRle(RleStr, 0, Bmp, 0, 0, true);

  RleStr.Free;
end;

// Pal Palette

constructor TPalPalette.Create;
var
  k: integer;
begin
  FBuffer := TMemoryStream.Create;
  FBuffer.LoadFromFile(PalPath + 'PAT.MKF');
  FBuffer.Read(k, 4);
  FPatCount := (k div 4) - 2;
end;

destructor TPalPalette.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

function TPalPalette.Pal0Color(index: byte): integer;
var
  p: PByte;
begin
  p := FBuffer.Memory;
  Inc(p, $0028 + index * 3);
  Result := p^ shl 2;
  Inc(p);
  Result := Result + (p^ shl 10);
  Inc(p);
  Result := Result + (p^ shl 18);
end;

function TPalPalette.Get(index: integer): PPalRecs;
begin
  Result := FBuffer.Memory;
  if index >= 11 then Exit;
  Inc(PByte(Result), $0028);
  Inc(Result, Index);
end;

end.
