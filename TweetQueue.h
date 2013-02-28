#ifndef TWEET_QUEUE_H
#define TWEET_QUEUE_H
#include "TinyBlogMsg.h"
	
typedef struct tweet {
	nx_uint16_t sourceMoteID;
	nx_uint8_t msg[DATA_SIZE];
	nx_uint8_t nchars;
	nx_uint32_t mood;
	nx_uint8_t seqno;
	
}Tweet;

#endif