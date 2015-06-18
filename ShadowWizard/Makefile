all: libgeom.so

GCC=gcc
#GCC=mingw32-gcc

libgeom.so: geom.c Makefile
	$(GCC) -Wall -O3 -shared -fPIC geom.c -o libgeom.so

