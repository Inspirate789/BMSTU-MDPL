#include <gtest/gtest.h>
#include <cstring>
#include <iostream>
#include "mystrlen.h"

#define LONG_STR_LEN 1025
#define SIMPLE_STR_LEN 128

extern "C" // в программе на чистом Си достаточно было бы написать "extern char *_strncpy(char *dst, const char *src, size_t n);"
{
    char *_strncpy(char *dst, const char *src, size_t n);
}

TEST(mystrlen, simple_test)
{
    const char *str = "Hello, World!";
    EXPECT_EQ(mystrlen(str), strlen(str));
}

TEST(mystrlen, empty_string)
{
    const char *str = "\0";
    EXPECT_EQ(mystrlen(str), strlen(str));
}

TEST(mystrlen, one_symbol)
{
    const char *str = "A";
    EXPECT_EQ(mystrlen(str), strlen(str));
}

TEST(mystrlen, long_string)
{
    char str[LONG_STR_LEN];

    for (size_t i = 0; i < LONG_STR_LEN - 1; ++i)
        str[i] = i % 10;
    
    str[LONG_STR_LEN] = '\0';

    EXPECT_EQ(mystrlen(str), strlen(str));
}

TEST(mystrncpy_simple, simple_test)
{
    const char *src = "Hello, World!";
    char *dst1 = new char[strlen(src) + 1];
    char *dst2 = new char[strlen(src) + 1];

    char *new_dst1 = strncpy(dst1, src, strlen(src));
    char *new_dst2 = _strncpy(dst2, src, strlen(src));

    EXPECT_STREQ(dst1, dst2);
    EXPECT_STREQ(new_dst1, new_dst2);
    
    delete[] dst1;
    delete[] dst2;
}

TEST(mystrncpy_simple, empty_string)
{
    const char *src = "\0";
    char *dst1 = new char[1];
    char *dst2 = new char[1];
    *dst1 = '\0';
    *dst2 = '\0';

    char *new_dst1 = strncpy(dst1, src, strlen(src));
    char *new_dst2 = _strncpy(dst2, src, strlen(src));

    EXPECT_STREQ(dst1, dst2);
    EXPECT_STREQ(new_dst1, new_dst2);

    delete[] dst1;
    delete[] dst2;
}

TEST(mystrncpy_simple, one_symbol)
{
    const char *src = "A";
    char *dst1 = new char[2];
    char *dst2 = new char[2];
    dst1[1] = '\0';
    dst2[1] = '\0';

    char *new_dst1 = strncpy(dst1, src, strlen(src));
    char *new_dst2 = _strncpy(dst2, src, strlen(src));

    EXPECT_STREQ(dst1, dst2);
    EXPECT_STREQ(new_dst1, new_dst2);
    
    delete[] dst1;
    delete[] dst2;
}

TEST(mystrncpy_simple, long_string)
{
    char src[LONG_STR_LEN];
    char *dst1 = new char[LONG_STR_LEN];
    char *dst2 = new char[LONG_STR_LEN];

    for (size_t i = 0; i < LONG_STR_LEN - 1; ++i)
        src[i] = i % 10;
    
    src[LONG_STR_LEN] = '\0';

    char *new_dst1 = strncpy(dst1, src, strlen(src));
    char *new_dst2 = _strncpy(dst2, src, strlen(src));

    EXPECT_STREQ(dst1, dst2);
    EXPECT_STREQ(new_dst1, new_dst2);
    
    delete[] dst1;
    delete[] dst2;
}

// TEST(mystrncpy_simple, too_long_copy_counter)
// {
//     const char *src = "Hello, World!";
//     char *dst1 = new char[strlen(src) + 1];
//     char *dst2 = new char[strlen(src) + 1];

//     char *new_dst1 = strncpy(dst1, src, LONG_STR_LEN);
//     char *new_dst2 = _strncpy(dst2, src, LONG_STR_LEN);

//     EXPECT_STREQ(dst1, dst2);
//     EXPECT_STREQ(new_dst1, new_dst2);
    
//     delete[] dst1;
//     delete[] dst2;
// }

TEST(mystrncpy_with_override, src_lt_dst)
{
    char buf1[] = "abcdefghijklmnopqrsto";
    char buf2[] = "abcdefghijklmnopqrsto";

    char *dst1 = strncpy(buf1 + 5, buf1, 10);
    char *dst2 = _strncpy(buf2 + 5, buf2, 10);

    EXPECT_EQ(strncmp(buf1, buf2, 20), 0);
    EXPECT_STREQ(dst1, dst2);
}

TEST(mystrncpy_with_override, src_gt_dst)
{
    char buf1[] = "abcdefghijklmnopqrsto";
    char buf2[] = "abcdefghijklmnopqrsto";

    char *dst1 = strncpy(buf1, buf1 + 5, 10);
    char *dst2 = _strncpy(buf2, buf2 + 5, 10);

    EXPECT_EQ(strcmp(buf1, buf2), 0);
    EXPECT_STREQ(dst1, dst2);
}

int main(int argc, char *argv[])
{
    std::cout << "MY TESTS:" << std::endl;

    std::cout << "SRC less than DST:" << std::endl;
    char buf1[] = "abcdefghijklmnopqrsto";
    char buf2[] = "abcdefghijklmnopqrsto";

    std::cout << "SRC:      " << buf1 << std::endl;

    strncpy(buf1 + 5, buf1, 10);
    _strncpy(buf2 + 5, buf2, 10);

    std::cout << "strncpy:  " << buf1 << std::endl;
    std::cout << "_strncpy: " << buf2 << std::endl;

    std::cout << "strcmp: " << strcmp(buf1, buf2) << std::endl << std::endl;



    std::cout << "DST less than SRC:" << std::endl;
    char buf3[] = "abcdefghijklmnopqrsto";
    char buf4[] = "abcdefghijklmnopqrsto";

    std::cout << "SRC:      " << buf3 << std::endl;

    strncpy(buf3, buf3 + 5, 10);
    _strncpy(buf4, buf4 + 5, 10);

    std::cout << "strncpy:  " << buf3 << std::endl;
    std::cout << "_strncpy: " << buf4 << std::endl;

    std::cout << "strcmp: " << strcmp(buf3, buf4) << std::endl;
    


    std::cout << std::endl << "GOOGLE TESTS:" << std::endl;
    ::testing::InitGoogleTest(&argc, argv);

    return RUN_ALL_TESTS();
}
