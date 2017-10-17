//import std.stdio;
//import core.stdc.stdio;
//import core.stdc.stdlib;
//import core.stdc.string;
import core.thread;

import pegged.grammar;
import arithmetic;
import std.conv: to;

//import MemoryModule;

static immutable ubyte[] libcurl_dll = cast(immutable ubyte[]) import("libcurl.dll");
//static ubyte[] libcurl_dll = cast(ubyte[]) import("libcurl.dll");

char[] toString(char* s)
{
  import core.stdc.string: strlen;
  return s ? s[0 .. strlen(s)] : cast(char[])null;
}

// http://forum.dlang.org/post/c6ojg9$c8p$1@digitaldaemon.com
/*
wchar[] toString(wchar* s)
{
  import core.stdc.wchar_;
  return s ? s[0 .. wcslen(s)] : cast(wchar[])null;
}
*/

void main()
{
  import std.stdio;

  //fprintf(stdout, "test1\n");
  //printf("%f\n", interpreter("1"));
  writeln(interpreter("1"));
  auto p1 = Arithmetic("1+2");
  writeln(p1.matches);
  writeln(p1);
  assert(interpreter("-1") == -1.0);
  assert(interpreter("1+1") == 2.0);
  assert(interpreter("1-1") == 0.0);
  //printf("test2\n");
  stdout.flush(); // for std.stdio
  //fflush(stdout); // for core.stdc.stdio
  //Thread.sleep( dur!("msecs")( 5000 ) );
  //getchar();
  version(none)
  asModule("arithmetic","arithmetic",
           "Arithmetic:
    Expr     <- Factor AddExpr*
    AddExpr  <- ('+'/'-') Factor
    Factor   <- Primary MulExpr*
    MulExpr  <- ('*'/'/') Primary
    Primary  <- Parens / Number / Variable / '-' Primary

    Parens   <- '(' Expr ')'
    Number   <~ [0-9]+
    Variable <- identifier
");
  version(none)
  {
    void * handle = MemoryLoadLibrary(&libcurl_dll[0]);
  }
  version(none)
  {
	import std.file : write;
	//write("libcurl.dll", libcurl_dll);
	write("lib/libcurl.dll", libcurl_dll);
    import core.sys.windows.windows : GetProcAddress, GetModuleHandleA, LoadLibraryA;
    void* handle;
    handle = LoadLibraryA("lib/libcurl.dll");
  }
  {
    import std.stdio;
    import std.net.curl;
    //import my.net.curl;
    foreach (chunk; byChunk("dlang.org", 20)) {
      writeln(chunk);
      stdout.flush();
    }
  }
  {
    import std.file;
    import std.path;
    writeln(thisExePath());
    string exe = thisExePath();
    writeln( dirName(exe) );
  }

  {
    import x;
    import std.utf;
    import std.conv: to;

    string app = "Sample Application/1.0";
    string url = "https://raw.githubusercontent.com/cyginst/ms2inst-v1/master/ms2inst.bat";
    my_winhttp_stream * stream = my_winhttp_stream_open(cast(wchar *)toUTF16z(app), cast(wchar *)toUTF16z(url));
    if (stream !is null) {
      uint dwSize;
      char * lpData = my_winhttp_stream_read_all(stream, &dwSize);
      char [] strData = toString( lpData );
      writeln( dwSize );
      string r1 = to!string(lpData);
      //wstring r1 = to!wstring(lpData);
      //wchar[] r2 = lpData[0 .. strlen(lpData)];
      writeln( strData );
      my_winhttp_stream_close(stream);
    }
  }

}

void func1() {
  import std.stdio;
  writeln("test0");
  stdout.flush(); // for std.stdio
}

void func2() {
  import core.stdc.stdio;
  fprintf(stdout, "test1\n");
  printf("test2\n");
  fflush(stdout); // for core.stdc.stdio
}

float interpreter(string expr)
{
    auto p = Arithmetic(expr);

    //writeln(p);

    float value(ParseTree p)
    {
      //writeln(p.name);
      //stdout.flush();
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

/+
struct ParseTree
{
    string name; /// The node name
    bool successful; /// Indicates whether a parsing was successful or not
    string[] matches; /// The matched input's parts. Some expressions match at more than one place, hence matches is an array.

    string input; /// The input string that generated the parse tree. Stored here for the parse tree to be passed to other expressions, as input.
    size_t begin, end; /// Indices for the matched part (from the very beginning of the first match to the last char of the last match.

    ParseTree[] children; /// The sub-trees created by sub-rules parsing.

    /**
    Basic toString for easy pretty-printing.
    */
    string toString(string tabs = "") const
    {
        string result = name;

        string childrenString;
        bool allChildrenSuccessful = true;

        foreach(i,child; children)
        {
            childrenString ~= tabs ~ " +-" ~ child.toString(tabs ~ ((i < children.length -1 ) ? " | " : "   "));
            if (!child.successful)
                allChildrenSuccessful = false;
        }

        if (successful)
        {
            result ~= " " ~ to!string([begin, end]) ~ to!string(matches) ~ "\n";
        }
        else // some failure info is needed
        {
            if (allChildrenSuccessful) // no one calculated the position yet
            {
                Position pos = position(this);
                string left, right;

                if (pos.index < 10)
                    left = input[0 .. pos.index];
                else
                    left = input[pos.index-10 .. pos.index];
                //left = strip(left);

                if (pos.index + 10 < input.length)
                    right = input[pos.index .. pos.index + 10];
                else
                    right = input[pos.index .. $];
                //right = strip(right);

                result ~= " failure at line " ~ to!string(pos.line) ~ ", col " ~ to!string(pos.col) ~ ", "
                       ~ (left.length > 0 ? "after " ~ left.stringified ~ " " : "")
                       ~ "expected "~ (matches.length > 0 ? matches[$-1].stringified : "NO MATCH")
                       ~ ", but got " ~ right.stringified ~ "\n";
            }
            else
            {
                result ~= " (failure)\n";
            }
        }

        return result ~ childrenString;
    }

    @property string failMsg()
    {
        foreach(i, child; children)
        {
            if (!child.successful)
                return child.failMsg;
        }

        if (!successful)
        {
            Position pos = position(this);
            string left, right;

            if (pos.index < 10)
                left = input[0 .. pos.index];
            else
                left = input[pos.index - 10 .. pos.index];

            if (pos.index + 10 < input.length)
                right = input[pos.index .. pos.index + 10];
            else
                right = input[pos.index .. $];

            return "Failure at line " ~ to!string(pos.line) ~ ", col " ~ to!string(pos.col) ~ ", "
                ~ (left.length > 0 ? "after " ~ left.stringified ~ " " : "")
                ~ "expected " ~ (matches.length > 0 ? matches[$ - 1].stringified : "NO MATCH")
                ~ `, but got ` ~ right.stringified;
        }

        return "Success";
    }

    ParseTree dup() @property
    {
        ParseTree result = this;
        result.matches = result.matches.dup;
        result.children = map!(p => p.dup)(result.children).array();
        return result;
    }
}
+/
