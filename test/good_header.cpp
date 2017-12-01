#include "good_header.h"


int main(int argc, char **)
{
    std::vector<int> vector;
    vector.push_back(argc);
    return vector.at(0);
}
