# Простой makefile для сборки, запуска и просмотра проассемблированного кода программы
# Написан под Linux
# Код написан под соглашение о вызове elf64 (Executable and Linkable Format), предназначенное для UNIX-подобных операционных систем
# Установка ассемблера nasm для Arch: "$ sudo pacman -S nasm"
# При компиляции mystrlen.cpp использую опцию "-masm=intel", чтобы скомпилировалась ассемблерная вставка, написанная не на нативном, а на синтаксисе Intel

test.exe: main.cpp mystrlen.cpp mystrlen.h mystrncpy.asm
	g++ -std=c++20 -Werror -Wall -Wpedantic -Wextra -c main.cpp -o main.o
	g++ -std=c++20 -Werror -Wall -Wpedantic -Wextra -c mystrlen.cpp -masm=intel -o mystrlen.o
	nasm -f elf64 mystrncpy.asm -o mystrncpy.o
	g++ main.o mystrlen.o mystrncpy.o -o test.exe -lgtest -lgtest_main -lpthread

.PHONY: run assembly clean

run: test.exe
	./test.exe

assembly:
	g++ -S mystrlen.cpp -o mystrlen.s
	cat mystrlen.s

clean:
	rm -f *.s *.o *.exe
