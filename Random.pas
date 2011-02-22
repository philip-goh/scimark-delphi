unit Random;

interface

uses
  SysUtils, StrUtils, Math, Array2D;

type
  TRIntArray = array[0..16] of Integer;
  TRandom = class
    public
      m : TRIntArray;
      seed : integer;
      i : integer;
      j : integer;
      haveRange : Boolean;
      left : double;
      right: double;
      width : double;

      constructor Create(seedArg : integer);
      function NextDouble() : double;
      function RandomVector(N : integer) : TArrayOf<double>;
      function RandomMatrix(Rows, Columns : integer) : Tarray2D;
    private
      procedure Initialise(seedArg : integer);
  end;

const
  MDIG = 32;
  ONE = 1;
  M1 = (ONE shl (MDIG-2)) + ((ONE shl (MDIG-2) )- ONE) ;
  M2 = ONE shl (MDIG div 2);
  DM1 = 1.0 / M1;

implementation



constructor TRandom.Create(seedArg: Integer);
begin
  Initialise(seedArg);

  self.left := 0.0;
  self.right := 1.0;
  self.width := 1.0;
  self.haveRange := False;
end;

procedure TRandom.Initialise(seedArg: Integer);
var
  jseed, k0, k1, j0, j1, iloop : integer;
begin
  self.seed := seedArg;

  seed := abs(seed);
  jseed := min(seed, m1);

  if jseed mod 2 = 0 then
    dec(jseed);

  k0 := 9069 mod m2;
  k1 := 9069 div m2;
  j0 := jseed mod m2;
  j1 := jseed div m2;

  for iloop := 0 to High(self.m) do
  begin
    jseed := j0 * k0;
    j1 := (jseed div m2 + j0 * k1 + j1 * k0) mod (m2 div 2);
    j0 := jseed mod m2;
    self.m[iloop] := j0 + m2 * j1;
  end;

  self.i := 4;
  self.j := 16;
end;



function TRandom.NextDouble;
var
  k : integer;

begin

  k := m[i] - m[j];
  if k < 0 then
    k := k + M1;

  m[j] := k;

  if i = 0 then
    i := 16
  else
    dec(i);

  if j = 0 then
    j := 16
  else
    dec(j);

  if haveRange = True then
    Result := left + DM1 * k * width
  else
    Result := DM1 * k;

end;

function TRandom.RandomVector(N : integer) : TArrayOf<double>;
var
  i : integer;
  arr : TArrayOf<double>;
begin
  SetLength(arr, N);
  for i := 0 to N - 1 do
    arr[i] := NextDouble;
  Result := arr;
end;

function TRandom.RandomMatrix(Rows, Columns : integer) : Tarray2D;
var
  i, j : integer;
begin
  Result := CreateArray2D(Rows, Columns);

  for i := 0 to Rows - 1 do
    for j := 0 to Columns - 1 do
      Result[i, j] := NextDouble;

end;

end.
