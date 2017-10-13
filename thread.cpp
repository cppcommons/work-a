// http://kaworu.jpn.org/cpp/std::thread::thread
// std::thread::thread - C++入門
#include <iostream>
#include <thread>
#include <exception>
using namespace std;
class do_work {
        int     x;
        public:
                do_work(): x(0) {}
                void operator()() {
                        //std::cout << __PRETTY_FUNCTION__ << std::endl;
                        std::cout << __FUNCSIG__ << std::endl;
                        x++;
                }
                int get_data() {
                        return (x);
                }
};
 
int
main (int argc, char *argv[]) {
        try {
                do_work do_worker1;
                std::thread t1(do_worker1); // コピーを渡す
                t1.join();
                cout << do_worker1.get_data() << endl;
                std::thread t2(std::ref(do_worker1)); // 参照を渡す
                t2.join();
                cout << do_worker1.get_data() << endl;
        } catch (std::exception &ex) {
                std::cerr << ex.what() << std::endl;
        }
        return (0);
}
