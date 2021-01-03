program mainOnly
  var i, y, res : int
  begin
    i := 0;
    y := 0;
    res := 0;
    while i < 5 do
    begin
        i := i + 1;
        while y < 5 do
        begin
            y := y + 1;
            res := res + 1;
        end;
        y := 0;
    end;
    write res;
  end