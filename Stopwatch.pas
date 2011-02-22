unit Stopwatch;

interface

uses
  WinProcs;

type
  TStopWatch = class
  private
    running : Boolean;
    last_time : double;
    total : double;

  public
    constructor Create;
    procedure Reset;
    procedure Start;
    procedure Resume;
    procedure Stop;
    function Read : double;
  end;

implementation

function seconds : double;
begin
  Result := GetTickCount / 1000.0;
end;

constructor TStopWatch.Create;
begin
  Reset;
end;

procedure TStopWatch.Reset;
begin
  running := False;
  last_time := 0;
  total := 0;
end;

procedure TStopWatch.Start;
begin
  if running = False then
  begin
    running := True;
    total := 0.0;
    last_time := seconds;
  end;
end;

procedure TStopWatch.Resume;
begin
  if running = False then
  begin
    running := True;
    last_time := seconds;
  end;
end;

procedure TStopWatch.Stop;
begin
  if running = True then
  begin
    total := total + seconds - last_time;
    running := False;
  end;
end;

function TStopWatch.Read;
var
  t : double;
begin

  if running = True then
  begin
    t := seconds;
    total := total + t - last_time;
    last_time := t;
  end;

  Result := total;
end;

end.
