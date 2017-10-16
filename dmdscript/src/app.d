import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;
import core.thread;

void main()
{
  fprintf(stdout, "test1\n");
  printf("test2\n");
  fflush(stdout);
  Thread.sleep( dur!("msecs")( 5000 ) );
}
