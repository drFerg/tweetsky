#ifndef INTEREST_H
#define INTEREST_H
#include "TinyBlogMsg.h"

#define BUFFSIZE 32

typedef struct interest{
	nx_uint16_t tweeterID;
	nx_uint16_t senderID;
	nx_uint8_t ttl;
}Interest;

#endif /* INTEREST_H */