program mainOnly
  var i :int;
  var val : array[-4..-3,1...100] of int;
  begin
      val[1,3] := 10;
      write val[1,3];
  end
