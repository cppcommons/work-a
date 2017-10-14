import std.stdio;

unittest {
  assert(1==1);
  assert(1==2);
  assert(1==1);
}

version(unittest) {}
else
void main()
{
	writeln("Edit source/app.d to start your project.");
}
