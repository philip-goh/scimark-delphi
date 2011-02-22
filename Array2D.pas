Unit Array2D;

Interface

Uses
  Sysutils;

Type
    TArrayOf<T> = Array Of T;
    TArray2D = Array of TArrayOf<Double>;

    function CreateArray2D(rows, columns : integer) : TArray2D;
    procedure SwapRow(rowA, rowB : integer; const arr : TArray2D);
    function CopyArray2D(const source: TArray2D) : TArray2D;

Implementation

function CreateArray2D(rows, columns : integer) : TArray2D;
var
  i : integer;
begin
  SetLength(Result, rows);
  for i := 1 to columns do
  begin
    SetLength(Result[i - 1], columns);
  end;
end;

procedure SwapRow(rowA, rowB : integer; const arr : TArray2D);
var
  temp : TArrayOf<Double>;
begin
  temp := arr[rowA];
  arr[rowA] := arr[rowB];
  arr[rowB] := temp;
end;

function CopyArray2D(const source: TArray2D) : TArray2D;
var
  rows, columns, i, j : integer;
begin
  rows := High(source) + 1;
  columns := High(source[0]) + 1;

  SetLength(Result, rows);
  for j := 0 to rows - 1 do
  begin
    SetLength(Result[j], columns);
    for i := 0 to columns - 1 do
      Result[j, i] := source[j, i];
  end;
end;


End.
