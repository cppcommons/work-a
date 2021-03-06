//import std.stdio;
//import core.stdc.stdio;
//import core.stdc.stdlib;
//import core.stdc.string;
import core.thread;

import pegged.grammar;
import std.conv: to;

mixin(grammar(`
M2Pkgs:
    #List     < Elem* / " "*
    #List     < Elem* eoi
    List     < Pkg* eoi
    Elem     < Pkg / :Delim / :Parens
    #Pkg      <- identifier
    Pkg      <~ (Letter+ "/" Letter+) / Letter+
    Letter   <- [a-zA-Z0-9]
    Delim    <- "," / ";"
    Parens   <~ "(" (!")" .)* ")"
    Spacing <- (space / Parens / Delim)*
    # dummy
`));

char[] toString(char* s)
{
  import core.stdc.string: strlen;
  return s ? s[0 .. strlen(s)] : cast(char[])null;
}

// http://forum.dlang.org/post/c6ojg9$c8p$1@digitaldaemon.com
wchar[] toString(wchar* s)
{
  import core.stdc.wchar_;
  return s ? s[0 .. wcslen(s)] : cast(wchar[])null;
}

void main()
{
  import std.stdio;

  {
    import std.stdio;
    import std.net.curl;
    //import my.net.curl;
    
    foreach (chunk; byChunkAsync("https://raw.githubusercontent.com/cyginst/ms2inst-v1/master/binaries/msys2-i686-20161025.7z", 20)) {
      //writeln(chunk);
      writeln(".");
      stdout.flush();
    }
  }

  {
    //import core.stdc.stdlib: getenv;
    import std.process: environment;
    import std.string: strip;
    string pkgs = environment.get("MSYS2_PKGS");
    writefln("pkgs.length=%d", pkgs.length);
    writefln("pkgs=%s", pkgs);
    if (strip(pkgs)=="") {
      writeln("empty pkgs");
      return;
    }
    auto p = M2Pkgs(pkgs);
    writeln(p);
    if (!p.successful) {
      writeln("not success!");
      return;
    }
    writeln(p);
    if (p.end != pkgs.length) {
      writeln("length does not match!");
      return;
    }
    writeln(p.matches.length);
    for (int i=0; i<p.matches.length; i++) {
      writefln("%d: %s", i, p.matches[i]);
    }
  }


  {
    import std.file;
    import std.path;
    writeln(thisExePath());
    string exe = thisExePath();
    writeln( dirName(exe) );
  }

  version(none)
  {
    
    import x;
    import std.utf;
    import std.conv: to;

    string app = "Sample Application/1.0";
    string url = "https://raw.githubusercontent.com/cyginst/ms2inst-v1/master/ms2inst.bat";
    my_winhttp_stream * stream = my_winhttp_stream_open(cast(wchar *)toUTF16z(app), cast(wchar *)toUTF16z(url));
    if (stream !is null) {
      writeln( to!string(stream.szHostName) );
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

  {
    import std.conv: to;
    import std.string: toStringz;
    import std.windows.charset: fromMBSz, toMBSz;
    string kanji = "kanji=漢字";
    writeln(kanji);
    string sjis = to!(string)(toMBSz(kanji));
    writeln("utf8 to sjis : ", sjis);
    writeln("sjis to utf8 : ", fromMBSz(toStringz(cast(char[])sjis)));

    wstring wkanji = to!wstring(kanji);
    writeln(wkanji);
    //writeln("utf8 to sjis : ", to!(string)(toMBSz(wkanji)));
  }

  {
    import std.path;
    string rsrcDir = std.path.expandTilde("~/myresources");
    writeln(rsrcDir);
  }

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
