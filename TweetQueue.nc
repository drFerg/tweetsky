#include "TweetQueue.h"

interface TweetQueue {
	command void add_tweet(tinyblog_t *tweet);
	command Tweet pop_tweet();
	command bool has_tweets();
}


