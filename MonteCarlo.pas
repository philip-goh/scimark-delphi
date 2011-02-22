unit MonteCarlo;

interface

uses
  Random;

const
  SEED = 113;

function MonteCarlo_integrate(Num_samples : integer) : double;
function MonteCarlo_num_flops(Num_samples : integer) : double;

implementation

function MonteCarlo_integrate(Num_samples : integer) : double;
var
  R : TRandom;
  under_curve, count : integer;
  x, y : double;
begin
  R := TRandom.Create(SEED);

  under_curve := 0;
  for count := 1 to Num_samples do
  begin
    x := R.NextDouble;
    y := R.NextDouble;

    if x * x + y * y <= 1.0 then
      inc(under_curve);

  end;

  R.Destroy;

  Result := (under_curve div Num_samples) * 4.0;
end;

function MonteCarlo_num_flops(Num_samples : integer) : double;
begin
  Result := Num_samples * 4.0;
end;

end.
