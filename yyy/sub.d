module sub;

import std.stdio;

int add2(int a, int b) { return a + b; }

unittest {
  writeln("test start");
  assert(1==1);
  assert(1==add2(1,2));
  assert(1==1);
  writeln("test success");
}


unittest {
  assert(1==add2(1,2));
}
