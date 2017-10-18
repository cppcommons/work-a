/* Converted to D from d.h by htod */
module d;
//C     typedef int (*func)(int a, int b);
extern (C):
alias int  function(int a, int b)func;

//C     struct A {
//C         func func;
//C     };
struct A
{
    func func;
}

//C     extern struct A g1_A;
extern A g1_A;
//C     extern struct A *g2_A;
extern A *g2_A;
