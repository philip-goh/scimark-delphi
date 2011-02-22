unit SOR;

interface

uses
  Array2D;

function SOR_num_flops(M, N, num_iterations : integer) : double;
procedure SOR_execute(M, N : integer; omega : double; const G : TArray2D; num_iterations : integer);


implementation

function SOR_num_flops(M, N, num_iterations : integer) : double;
begin
   Result := (M - 1) * (N - 1) * num_iterations * 6.0;
end;

procedure SOR_execute(M, N : integer; omega : double; const G : TArray2D; num_iterations : integer);
var
  omega_over_four : double;
  one_minus_omega : double;
  Mm1, Nm1, p, i, j : integer;
begin
  omega_over_four := omega * 0.25;
  one_minus_omega := 1.0 - omega;

  Mm1 := M - 1;
  Nm1 := N - 1;

  for p := 1 to num_iterations do
    for i := 1 to Mm1 - 1 do
      for j := 1 to Nm1 - 1 do
      begin
        G[i, j] := omega_over_four * (G[i-1, j] + G[i+1, j] + G[i, j-1] + G[i, j+1])
                   + one_minus_omega * G[i,j];
      end;

end;

end.
