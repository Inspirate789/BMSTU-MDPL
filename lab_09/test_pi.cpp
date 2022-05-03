#include <iostream>
#include <cmath>

#define PRECISION "%.12f"

double sin_pi()                             // обёртка над ассемблерной вставкой, считающей sin(pi)
{
    double res;

    __asm__("fldpi\n\t"                     // загружаем константу пи на вершину стека сопроцессора
            "fsin\n\t"                      // считаем синус числа, находящегося в ST(0) (на вершине стекасопроцессора); операнд считается заданным в радианах
            "fstp %0\n\t"                   // извлекаем число из FPU в память, в данном случае из ST(0) в res
            : "=m" (res)                    // res - выходной параметр
            );

    return res;
}

double sin_half_pi()                        // обёртка над ассемблерной вставкой, считающей sin(pi / 2)
{
    double res;
    const int divider = 2;
    
    __asm__("fldpi\n\t"                     // загружаем константу пи на вершину стека сопроцессора
            "fild %1\n\t"                   // загружаем divider (целое число, поэтому 'i' в названии команды) на вершину стека
            "fdivp\n\t"                     // делим ST(1) на ST(0), сохраняем результат в ST(1) и извлекаем из стека сопроцессора (поэтому 'p' в названии команды)
            "fsin\n\t"                      // считаем синус числа, находящегося в ST(0) (на вершине стекасопроцессора); операнд считается заданным в радианах
            "fstp %0\n\t"                   // извлекаем число из FPU в память, в данном случае из ST(0) в res
            : "=m" (res)                    // res - выходной параметр
            : "m" (divider)                 // divider - входной параметр; да-да, я послал сюда число 2 через переменную, чтобы не возиться с загрузкой числа в стек сопроцессора
            );

    return res;
}

int main()
{
    printf("\nTest PI: \n");
    
    printf("LIB sin(3.14) =      " PRECISION "\n", sin(3.14));
    printf("LIB sin(3.141596) = " PRECISION "\n", sin(3.141596));
    printf("LIB sin(M_PI) =      " PRECISION "\n", sin(M_PI));
    printf("FPU sin(PI) =       " PRECISION "\n", sin_pi());
    
    printf("\nTest PI / 2: \n");

    printf("LIB sin(3.14 / 2) =     " PRECISION "\n", sin(3.14 / 2));
    printf("LIB sin(3.141596 / 2) = " PRECISION "\n", sin(3.141596 / 2));
    printf("LIB sin(M_PI / 2) =     " PRECISION "\n", sin(M_PI / 2));
    printf("FPU sin(PI / 2) =       " PRECISION "\n", sin_half_pi());
    
    return 0;
}
