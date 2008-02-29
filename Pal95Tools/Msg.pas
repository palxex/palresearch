unit Msg;

interface

uses
  Windows, Classes, SysUtils;

type
  TPalMessages = class
  private
    FIndex: TMemoryStream;
    FMessage: TMemoryStream;
    FWords: TMemoryStream;
    function Get(index: integer): string;
    function GetWords(index: integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    property Text[index: integer]: string read Get; default;
    property Words[index: integer]: string read GetWords;
  end;

var
  PalMsg: TPalMessages;

implementation

uses
  Main, Decoder, CVCode;

constructor TPalMessages.Create;
begin
  FIndex := TMemoryStream.Create;
//  FIndex
  DecodeStream('sss.mkf', 3, False, FIndex);
  FMessage := TMemoryStream.Create;
  FMessage.LoadFromFile(PalPath + 'M.MSG');

  FWords := TMemoryStream.Create;
  FWords.LoadFromFile(PalPath + 'WORD.DAT');

end;

destructor TPalMessages.Destroy;
begin
  FWords.Free;
  FIndex.Free;
  FMessage.Free;
  inherited Destroy;
end;

function TPalMessages.Get(index: integer): string;
var
  b, e: integer;
begin
  Result := '';
  if (index < 0) or ( index >= ((FIndex.Size div 4) - 1) ) then Exit;
  Findex.Position := index * 4;
  Findex.read(b, 4);
  Findex.read(e, 4);
  SetLength(Result, e-b);
  FMessage.Position := b;
  FMessage.Read(Result[1], e-b);

  if isBig5 then Result := BIG5toGB(Result);
end;

function TPalMessages.GetWords(index: integer): string;
var
  buf: array [0..10] of Char;
begin
  Result := '';
  if (index < 0) or (index >= (FWords.Size div 10)) then Exit;
  FWords.Position := index * 10;
  FWords.Read(buf, 10);
  buf[10] := #0;
  Result := Trim(buf);
  
  if isBig5 then Result := BIG5toGB(Result);
end;

end.
