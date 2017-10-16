import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;
import core.thread;

import pegged.grammar;
import arithmetic;
import std.conv: to;

void main()
{
  fprintf(stdout, "test1\n");
  printf("%f\n", interpreter("1"));
  assert(interpreter("-1") == -1.0);
  assert(interpreter("1+1") == 2.0);
  assert(interpreter("1-1") == 0.0);
  printf("test2\n");
  fflush(stdout);
  //Thread.sleep( dur!("msecs")( 5000 ) );
  getchar();
}

float interpreter(string expr)
{
    auto p = Arithmetic(expr);

    //writeln(p);

    float value(ParseTree p)
    {
        switch (p.name)
        {
            case "Arithmetic":
                return value(p.children[0]);
            case "Arithmetic.Term":
                float v = 0.0;
                foreach(child; p.children) v += value(child);
                return v;
            case "Arithmetic.Add":
                return value(p.children[0]);
            case "Arithmetic.Sub":
                return -value(p.children[0]);
            case "Arithmetic.Factor":
                float v = 1.0;
                foreach(child; p.children) v *= value(child);
                return v;
            case "Arithmetic.Mul":
                return value(p.children[0]);
            case "Arithmetic.Div":
                return 1.0/value(p.children[0]);
            case "Arithmetic.Primary":
                return value(p.children[0]);
            case "Arithmetic.Parens":
                return value(p.children[0]);
            case "Arithmetic.Neg":
                return -value(p.children[0]);
            case "Arithmetic.Number":
                return to!float(p.matches[0]);
            default:
                return float.nan;
        }
    }

    return value(p);
}
