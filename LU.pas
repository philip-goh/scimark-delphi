unit LU;

interface

uses
  Array2D, SysUtils, Math;

function LU_num_flops(NArg : integer) : double;
procedure LU_factor(const A : TArray2D; pivot : TArrayOf<integer>);

implementation

function LU_num_flops(NArg : integer) : double;
var
  Nd : double;
begin
  Nd := NArg;
  Result :=  (2.0 * Nd *Nd *Nd/ 3.0);
end;

procedure LU_factor(const A : TArray2D; pivot : TArrayOf<integer>);
var
  minMN, M, N, j, jp, i, k, ii, jj : integer;
  t, ab, recp : double;
begin
  M := High(A);
  N := High(A[0]);

  minMN := Min(M, N);

  for j := 0 to minMN do
  begin
    jp := j;

    t := abs(A[j,j]);
    for i := j + 1 to M do
    begin
      ab := abs(A[i,j]);
      if ab > t then
      begin
        jp := i;
        t := ab;
      end;
    end;

    pivot[j] := jp;

    if A[jp, j] = 0 then
      Exit; //factorization failed because of zero pivot

    if jp <> j then
      Swaprow(j, jp, A);

    if j < M then
    begin
      recp := 1.0 / A[j,j];
      for k := j + 1 to M do
        A[k, j] := A[k, j] * recp;
    end;

    if j < minMN then
    begin
      for ii := j + 1 to M do
        for jj := j + 1 to N do
          A[ii, jj] := A[ii,jj] - (A[ii, j] * A[j, jj]);
    end;

  end;
end;

end.
