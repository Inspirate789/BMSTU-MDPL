#include <stdio.h>
#include <time.h>

#define REPEATS_COUNT 1e7

float c_scalar_prod(const float *a, const float *b, size_t n)
{
    float res = 0;

    for (size_t i = 0; i < n; ++i)
        res += a[i] * b[i];

    return res;
}

float sse_scalar_prod(float *src_a, float *src_b, size_t n)
{
    float tmp, res = 0;
    __float128 *a = (__float128 *)src_a;
    __float128 *b = (__float128 *)src_b;

    for (size_t i = 0; i < n; i += sizeof(__float128) / sizeof(float), a++, b++)
    {                                   // Находим скалярное произведение четвёрок (sizeof(__float128) / sizeof(float) = 4) элементов векторов
                                        //                                              xmm0                                                                                     xmm1
        __asm__(                        //                                               -                                                                                        -
            "movaps xmm0, %1\n"         //       |       x1       |       x2       |            x3           |            x4           |                                  -
            "movaps xmm1, %2\n"         //       |       x1       |       x2       |            x3           |            x4           |            |   y1  |   y2  |      y3     |      y4     |
            "mulps xmm0, xmm1\n"        //       |     x1*y1      |     x2*y2      |          x3*y3          |          x4*y4          |            |   y1  |   y2  |      y3     |      y4     |
            "movhlps xmm1, xmm0\n"      //       |     x1*y1      |     x2*y2      |          x3*y3          |          x4*y4          |            |   y1  |   y2  |    x1*y1    |    x2*y2    |
            "addps xmm0, xmm1\n"        //       |    x1*y1+y1    |    x2*y2+y2    |       x3*y3+x1*y1       |       x4*y4+x2*y2       |            |   y1  |   y2  |    x1*y1    |    x2*y2    |
            "movaps xmm1, xmm0\n"       //       |    x1*y1+y1    |    x2*y2+y2    |       x3*y3+x1*y1       |       x4*y4+x2*y2       |            | x1*y1 | x2*y2 | x3*y3+x1*y1 | x4*y4+x2*y2 |
            "shufps xmm0, xmm0, 1\n"    //       |    x1*y1+y1    |    x2*y2+y2    |       x3*y3+x1*y1       |       x3*y3+x1*y1       |            | x1*y1 | x2*y2 | x3*y3+x1*y1 | x4*y4+x2*y2 |
            "addps xmm0, xmm1\n"        //       | x1*y1+y1+x1*y1 | x2*y2+y2+x2*y2 | x3*y3+x1*y1+x3*y3+x1*y1 | x3*y3+x1*y1+x4*y4+x2*y2 |            | x1*y1 | x2*y2 | x3*y3+x1*y1 | x4*y4+x2*y2 |
            "movss %0, xmm0\n"          // Все действия после mulps (когда мы получили скалярное произведение 4-мерных векторов) мы сделали для того, чтобы получить в младших 32 битах xmm0 
            : "=m"(tmp)                 // сумму всех 32-битных частей xmm0 из занести её в результат (32-битную переменную). 
            : "m"(*a), "m"(*b)          // Да-да, тут используется именно такое преобразование типа: старшие 3/4 числа просто отбрасываются.
            : "xmm0", "xmm1"
            );
        
        res += tmp;
    }

    return res;
}

int main(void)
{
    float a = 1e3;
    float b = 1e-3;
    float c = 0.0;
    float d = 5.0;

    const size_t n = 16;
    float vec_a[16] = {a, b, c, d, a, b, d, c, b, a, c, d, a, b, c, d};
    float vec_b[16] = {d, c, b, a, d, a, b, d, c, b, a, c, d, a, b, b};

    clock_t start = clock();
    printf("The time of the scalar product of 16-dimensional vectors (%zu times):\n", (size_t)REPEATS_COUNT);
    for (size_t i = 0; i < REPEATS_COUNT; i++)
    {
        c_scalar_prod(vec_a, vec_b, n);
    }
    clock_t time_c = clock() - start;

    printf("C:   %zu ms\n", time_c);

    start = clock();
    for (size_t i = 0; i < REPEATS_COUNT; i++)
    {
        sse_scalar_prod(vec_a, vec_b, n);
    }
    clock_t time_asm = clock() - start;
    printf("Asm: %zu ms\n", time_asm);

    if (sse_scalar_prod(vec_a, vec_b, n) == c_scalar_prod(vec_a, vec_b, n))
        printf("\nThe results are the same.\n");
    else
        printf("\nThe results are different.\n");

    printf("\nAssembler implementation is %lf times faster than C implementation.\n", (double)time_c / time_asm);

    return 0;
}
