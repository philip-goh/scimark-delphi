unit FFT;

interface

uses
  Array2D;

function FFT_num_flops(N          : Integer) : Double;
procedure FFT_bitreverse(NArg : Integer; const DataArg : TArrayOf<Double>);
procedure FFT_transform(NArg  : integer; const DataArg : TArrayOf<Double>);
procedure FFT_inverse(NArg    : integer; const DataArg : TArrayOf<Double>);

const
    PI = 3.1415926535897932;

implementation

uses
  SysUtils, Classes;

function int_log2 (n : Integer) : Integer;
var
  k, log : Integer;
begin
  k := 1;
  log := 0;

  while k < n do
  begin
    k := k * 2;
    inc(log);
  end;

  if n <> 1 shl log then
  begin
    Writeln('FFT: Data length is not a power of 2!: ', n);
    Exit(1);
  end;

  Result := log;
end;

procedure FFT_transform_internal(NArg : Integer; const dataArg : TArrayOf<Double>; directionArg : Integer);
var
  n : integer;
  bit : integer;
  logn : integer;
  dual : integer;

  w_real, w_imag : Double;
  wd_real, wd_imag : Double;
  tmp_real, tmp_imag : Double;
  theta, s, t, s2 : Double;
  z1_real, z1_imag : Double;

  a, b : integer;
  i, j : integer;

begin
  n := NArg div 2;
  dual := 1;

  if (n = 1) Or (NArg = 0) then
    Exit;

  logn := int_log2(n);

  { bit reverse the input data for decimation in time algorithm }
  FFT_bitreverse(N, dataArg) ;

  for bit := 0 to logn - 1 do
  begin
    w_real := 1.0;
    w_imag := 0.0;

    theta := 2.0 * directionArg * PI / (2.0 * dual);
    s := sin(theta);
    t := sin(theta / 2.0);
    s2 := 2.0 * t * t;

    b := 0;
    while b < n do
    begin
      i := 2 * b;
      j := 2 * (b + dual);

      wd_real := dataArg[j];
      wd_imag := dataArg[j + 1];

      dataArg[j] := dataArg[i] - wd_real;
      dataArg[j + 1] := dataArg[i + 1] - wd_imag;
      dataArg[i] := dataArg[i] + wd_real;
      dataArg[i + 1] := dataArg[i + 1] + wd_imag;

      Inc(b, 2 * dual);
    end;

    for a := 1 to dual - 1 do
    begin
      tmp_real := w_real - s * w_imag - s2 * w_real;
      tmp_imag := w_imag + s * w_real - s2 * w_imag;
      w_real := tmp_real;
      w_imag := tmp_imag;

      b := 0;
      while b < n do
      begin
        i := 2*(b + a);
        j := 2*(b + a + dual);

        z1_real := dataArg[j];
        z1_imag := dataArg[j+1];

        wd_real := w_real * z1_real - w_imag * z1_imag;
        wd_imag := w_real * z1_imag + w_imag * z1_real;

        dataArg[j]   := dataArg[i]   - wd_real;
        dataArg[j+1] := dataArg[i+1] - wd_imag;
        dataArg[i]   := dataArg[i] + wd_real;
        dataArg[i+1] := dataArg[i+1] + wd_imag;

        Inc(b, 2 * dual);
      end;
    end;

    Inc(dual, dual);
  end;
end;

function FFT_num_flops(N : Integer) : Double;
var
  Nd, logN : Double;
begin
  Nd := N;
  logN := int_log2(N);

  Result := (5.0*Nd-2)*logN + 2*(Nd+1);
end;

procedure FFT_bitreverse(NArg : Integer; const DataArg : TArrayOf<Double>);
var
  n, nm1, i, j, ii, jj, k : integer;
  tmp_real, tmp_imag : Double;
begin
  n := NArg div 2;
  nm1 := n - 1;
  j := 0;

  for i := 0 to nm1 - 1 do
  begin
    ii := i * 2;
    jj := j * 2;
    k := n div 2;

    if i < j then
    begin
      tmp_real := dataArg[ii];
      tmp_imag := dataArg[ii+1];

      dataArg[ii]   := dataArg[jj];
      dataArg[ii+1] := dataArg[jj+1];
      dataArg[jj]   := tmp_real;
      dataArg[jj+1] := tmp_imag;
    end;

    while k <= j do
    begin
      j := j - k;
      k := k div 2;
    end;
  end;

end;

procedure FFT_transform(NArg : integer; const DataArg : TArrayOf<Double>);
begin
  FFT_transform_internal(NArg, DataArg, -1);
end;

procedure FFT_inverse(NArg : integer; const DataArg : TArrayOf<Double>);
var
  n, i : integer;
  norm : Double;
begin
  n := NArg div 2;

  FFT_transform_internal(NArg, DataArg, 1);

  norm := 1.0 / n;
  for i := 0 to NArg - 1 do
    DataArg[i] := DataArg[i] * norm;

end;

end.
