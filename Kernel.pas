unit Kernel;

interface

uses
  Random, Array2D, Stopwatch, FFT, SOR, MonteCarlo, SparseCompRow, LU;

function kernel_measureFFT(FFT_size : integer; min_time : double; R : TRandom) : double;
function kernel_measureSOR(SOR_size : integer; min_time : double; R : TRandom) : double;
function kernel_measureMonteCarlo(min_time : double; R : TRandom) : double;
function kernel_measureSparseMatMult(Sparse_size_N : integer; Sparse_size_nz : integer;
            min_time : double; R : TRandom) : double;
function kernel_measureLU(LU_size : integer; min_time : double; R : TRandom) : double;

implementation

function kernel_measureFFT(FFT_size : integer; min_time : double; R : TRandom) : double;
var
  twoN : integer;
  x : TArrayOf<Double>;
  cycles : Integer;
  Q : TStopWatch;
  i : integer;
begin
  twoN := 2 * FFT_size;
  cycles := 1;
  x := R.RandomVector(twoN);
  Q := TStopWatch.Create;

  while True do
  begin
    Q.Start;
    for i := 1 to cycles do
    begin
      FFT_transform(twoN, x);
      FFT_inverse(twoN, x);
    end;
    Q.Stop;

    if Q.Read >= min_time then
      Break;

    cycles := cycles * 2;
  end;

  Result := FFT_num_flops(FFT_Size) * cycles / Q.Read * 1.0e-6;

end;

function kernel_measureSOR(SOR_size : integer; min_time : double; R : TRandom) : double;
var
  G : TArray2D;
  Q : TStopWatch;
  cycles : integer;
begin
  G := R.RandomMatrix(SOR_size, SOR_size);
  Q := TStopWatch.Create;
  cycles := 1;

  while True do
  begin
    Q.Start;
    SOR_execute(SOR_Size, SOR_Size, 1.25, G, cycles);
    Q.Stop;

    if Q.Read >= min_time then
      Break;

    cycles := cycles * 2;
  end;

  result := SOR_num_flops(SOR_Size, SOR_Size, cycles) / Q.Read * 1.0e-6;
end;

function kernel_measureMonteCarlo(min_time : double; R : TRandom) : double;
var
  Q : TStopWatch;
  cycles : Integer;
begin
  Q := TStopWatch.Create;
  cycles := 1;

  while True do
  begin
    Q.Start;
    MonteCarlo_integrate(cycles);
    Q.Stop;
    if Q.Read >= min_time then
      Break;
    cycles := cycles * 2;
  end;

  result := MonteCarlo_num_flops(cycles) / Q.Read * 1.0e-6;
  Q.Destroy;
end;

function kernel_measureSparseMatMult(Sparse_size_N : integer; Sparse_size_nz : integer;
            min_time : double; R : TRandom) : double;
var
  x, y, val : TArrayOf<double>;
  nr, anz, ri, cycles : integer;
  col, row : TArrayOf<integer>;
  Q : TStopWatch;
  rowr, step, i : integer;
begin
  x := R.RandomVector(Sparse_size_N);
  SetLength(y, Sparse_size_N);

  nr := Sparse_size_nz div Sparse_size_N;
  anz := nr * Sparse_size_nz;

  val := R.RandomVector(anz);
  SetLength(col, Sparse_size_nz);
  SetLength(row, Sparse_size_N + 1);
  cycles := 1;

  Q := TStopWatch.Create;
  row[0] := 0;

  for ri := 0 to Sparse_size_N - 1 do
  begin
    rowr := row[ri];
    step := ri div nr;

    row[ri + 1] := rowr + nr;
    if step < 1 then
      step := 1;

    for i := 0 to nr - 1 do
      col[rowr+i] := i*step;
  end;

  while True do
  begin
    Q.Start;
    SparseCompRow_matmult(Sparse_size_n, y, val, row, col, x, cycles);
    Q.Stop;

    if Q.Read >= min_time then
      Break;

    cycles := cycles * 2;
  end;

  Result := SparseCompRow_num_flops(Sparse_size_N, Sparse_size_nz, cycles) /
            Q.Read * 1.0e-6;
  Q.Destroy;
end;

function kernel_measureLU(LU_size : integer; min_time : double; R : TRandom) : double;
var
  A, lu : TArray2D;
  pivot : TArrayOf<integer>;
  Q : TStopWatch;
  i, cycles : integer;
begin
  Q := TStopWatch.Create;
  cycles := 1;

  A := R.RandomMatrix(LU_size, LU_size);
  SetLength(pivot, LU_size);

  while True do
  begin
    Q.Start;
    for i := 0 to cycles - 1 do
    begin
      lu := CopyArray2D(A);
      LU_factor(lu, pivot);
    end;
    Q.Stop;

    if Q.Read >= min_time then
      Break;

    cycles := cycles * 2;
  end;

  result := LU_num_flops(LU_size) * cycles / Q.Read * 1.0e-6;
  Q.Destroy;

end;

end.
