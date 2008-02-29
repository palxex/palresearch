unit Scriptor;

interface

uses
  Windows, Classes, SysUtils, Forms;

type
  TScriptor = class(TStringList)
  private
    FDesc: TStrings;
  public
    constructor Create;
    function Trans(cmd, arg1, arg2, arg3: Word; var desc: string): string;
  end;

implementation

uses
  Msg;

constructor TScriptor.Create;
var
  ss: TStrings;
  i, j, k: integer;
  s: string;
begin
  ss := TStringList.Create;
  FDesc := TStringList.Create;
  ss.LoadFromFile(ExtractFilePath(Application.Exename) + 'scr_desc.txt');

  for i:=0 to ss.Count-1 do begin
    s := ss[i];
    if length(s) < 6 then Continue;
    if (s[1]<>'@') and (s[6]<>':') then Continue;

    j := StrToIntDef('$' + Copy(s, 2, 4), -1);
    if j < 0 then Continue;
    System.Delete(s, 1, 6);
    s := Trim(s);
    k := Pos(';', s);

    if k > 0 then begin
      AddObject(Trim(Copy(s, 1, k-1)) + ' ', TObject(j));
      FDesc.Add(Copy(s, k+1, 100));
    end else begin
      AddObject(Trim(s) + ' ', TObject(j));
      FDesc.Add('');
    end;
  end;
end;

function TScriptor.Trans(cmd, arg1, arg2, arg3: Word; var desc: string): string;

  function TransVal(const s: string; val: Word): string;
  begin
     if SameText(s, 'MessageID') then Result := '>' + PalMsg[val] else
     if SameText(s, 'Int16') then Result := IntToStr(Smallint(val)) else
     if SameText(s, 'Boolean') then
       if val = 0 then Result := 'false' else Result := 'true' else
     if SameText(s, 'FaceID') then Result := '[RGM]#' + IntToStr(val) else
     if SameText(s, 'BodyPartID') then
       case val of
         0: Result := 'All';
         1: Result := 'Head';
         2: Result := 'Neck';
         3: Result := 'Wearing';
         4: Result := 'Weapon';
         5: Result := 'Foot';
         6: Result := 'Hand';
        $b: Result := 'head';
        $c: Result := 'neck';
        $d: Result := 'wearing';
        $e: Result := 'weapon';
        $f: Result := 'foot';
       $10: Result := 'hand';
         else Result := '???';
       end else
     if SameText(s, 'AttributeID') then
       case val of
           0: Result := 'Portrait';
           1: Result := 'BattleMode';
           2: Result := 'MapMode';
           3: Result := 'Name';
           4: Result := 'CanAttackAll';
           5: Result := '???NoEffect';
           6: Result := 'Level';
           7: Result := 'MaxHP';
           8: Result := 'MaxMP';
           9: Result := 'HP';
          $a: Result := 'MP';
         $11: Result := 'Wushu';
         $12: Result := 'Dex';
         $13: Result := 'Armor';
         $14: Result := 'Shenfa';
         $15: Result := 'Luck';
         $16: Result := 'PoisonDef';
         $17: Result := 'WindDef';
         $18: Result := 'ThunderDef';
         $19: Result := 'WaterDef';
         $1a: Result := 'FireDef';
         $1b: Result := 'EarthDef';
         $41: Result := 'TeamMagic';
         else Result := '???';
       end else
     if SameText(s, 'Null') then Result := '[null]' else
    { if SameText(s, 'CharacterID') then
       if val = 0
         then Result := '[null]'
         else Result := PalMsg.Words[ val + 35 ]
     else {}
     Result := IntToHex(val, 4);
  end;

var
  i, k: integer;
  s, ss: string;
begin
  Result := '(??)';
  desc := '';
  i := 0;
  while (i<Count) and (cmd <> integer(Objects[i])) do Inc(i);
  if i >= Count then Exit;

  s := Self[i];
  desc := FDesc[i];

  k := Pos(' ', s);
  if k < 1 then Exit;
  Result := Copy(s, 1, k);
  System.Delete(s, 1, k);

  k := Pos(' ', s);
  if k < 1 then Exit;
  ss := Copy(s, 1, k-1);
  System.Delete(s, 1, k);
  Result := Result + '  ' + TransVal(ss, arg1);

  k := Pos(' ', s);
  if k < 1 then Exit;
  ss := Copy(s, 1, k-1);
  System.Delete(s, 1, k);
  Result := Result + '  ' + TransVal(ss, arg2);

  k := Pos(' ', s);
  if k < 1 then Exit;
  ss := Copy(s, 1, k-1);
  System.Delete(s, 1, k);
  Result := Result + '  ' + TransVal(ss, arg3);
end;

end.
