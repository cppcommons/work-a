import std.stdio;

int add2(int a, int b) { return a + b; }

unittest {
  x;
  writeln("test start");
  assert(1==1);
  assert(1==add2(1,2));
  assert(1==1);
  writeln("test success");
}

version(unittest) {}
else
void main()
{
	writeln("Edit source/app.d to start your project.");
}
