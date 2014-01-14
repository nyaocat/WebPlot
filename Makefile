
all: c1 c2


l1:l1.cpp
	g++ -DNDEBUG -O2 -o $@ $<  `pkg-config --cflags --libs plplotd-c++`
c2:c2.cpp
	g++ -DNDEBUG -O2 -o $@ $<  `pkg-config --cflags --libs plplotd-c++`
c1:c1.cpp
	g++ -DNDEBUG -O2 -o $@ $<  `pkg-config --cflags --libs plplotd-c++`
