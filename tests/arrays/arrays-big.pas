program mainOnly
  var i :int;
  var val : array[-4..-3,1...100,1..4,1..2] of int;
  var t :int;
  begin
      val[-3,1,2,1] := 10;
      write val[-3,1,2,1];
  end
