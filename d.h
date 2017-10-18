typedef int (*func)(int a, int b);

struct A {
    func func;
};

extern struct A g1_A;
extern struct A *g2_A;
