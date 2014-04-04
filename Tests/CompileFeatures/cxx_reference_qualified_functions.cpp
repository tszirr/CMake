
struct test{
  void f() & { }
  void f() && { }
};

int someFunc(){
  test t;
  t.f(); // lvalue
  test().f(); // rvalue
}
