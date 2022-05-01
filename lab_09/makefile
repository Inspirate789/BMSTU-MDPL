# Пояснение про некоторые опции gcc:
# -m80387 - заставляет компилятор генерировать инструкции для операций с плавающей запятой
# -mno-80387 - заставляет компилятор генерировать инструкции, использующие библиотечные вызовы для операций с плавающей запятой
# -mno-sse - запрещаем компилятору использовать регистры XMM/MMX и инструкции SSE

_MAKE_OUT_DIR_ := $(shell mkdir -p out)
_MAKE_ASM_DIR_ := $(shell mkdir -p assembly)
_MAKE_DISASM_DIR_ := $(shell mkdir -p disassembly)

.PHONY: math_sse math_fpu math_asm math pi run assembly disassembly clean

math_sse:
	@echo
	@echo "SSE: "
	g++ test_math.cpp -mno-80387 -DSSE -O0 -o test_math_sse.exe
	./test_math_sse.exe

math_fpu:
	@echo
	@echo "FPU: "
	g++ test_math.cpp -m80387 -mno-sse -DFLOAT_80 -O0 -o test_math_fpu.exe
	./test_math_fpu.exe

math_asm:
	@echo
	@echo "ASM: "
	g++ test_math.cpp -masm=intel -DASM -O0 -o test_math_asm.exe
	./test_math_asm.exe

math: math_sse math_fpu math_asm

pi:
	@echo
	g++ test_pi.cpp -masm=intel -o test_pi.exe
	./test_pi.exe

run: math pi

# Посмотреть ассемблерный код можно 2 способами:

assembly:
	g++ -S test_math.cpp -mno-80387 -DSSE -O0 -o assembly/test_math_sse.s
	g++ -S test_math.cpp -m80387 -mno-sse -DFLOAT_80 -O0 -o assembly/test_math_fpu.s
	g++ -S test_math.cpp -masm=intel -DASM -O0 -o assembly/test_math_asm.s
	g++ -S test_pi.cpp -masm=intel -o assembly/test_pi.s

disassembly:
	g++ -c test_math.cpp -mno-80387 -DSSE -O0 -o out/test_math_sse.o
	g++ -c test_math.cpp -m80387 -mno-sse -DFLOAT_80 -O0 -o out/test_math_fpu.o
	g++ -c test_math.cpp -masm=intel -DASM -O0 -o out/test_math_asm.o
	g++ -c test_pi.cpp -masm=intel -o out/test_pi.o
	objdump -M intel-mnemonic -d out/test_math_sse.o  > disassembly/test_math_sse.txt
	objdump -M intel-mnemonic -d out/test_math_fpu.o  > disassembly/test_math_fpu.txt
	objdump -M intel-mnemonic -d out/test_math_asm.o  > disassembly/test_math_asm.txt
	objdump -M intel-mnemonic -d out/test_pi.o  > disassembly/test_pi.txt

clean:
	rm -rf out/* assembly/* disassembly/* *.exe

