#include "TinyBlogMsg.h"
nx_uint8_t tinymsgs[DATA_SIZE][8];

interface TweetQueue {
	command void add_tweet(tinyblog_t *tweet);
	command void get_tweets();
}


