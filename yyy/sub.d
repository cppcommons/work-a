//import std.stdio;
import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;

/** this is add2 function.
これは add2 関数です。 */
int add2(int a, int b)
{
  return a + b;
}

unittest
{
  fprintf(stderr, "[stderr]\n");
  printf("[stdout]\n");
  //writeln("test start");
  assert(1 == 1);
  assert(3 == add2(1, 2));
  assert(1 == 1);
  //writeln("test success");
}

@safe
unittest
{
  assert(3 == add2(1, 2));
}
