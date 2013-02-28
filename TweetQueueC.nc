#include <stdlib.h>
#define QSIZE 8

module TweetQueueC {
	provides interface TweetQueue;
}

implementation{
	Tweet tweetStore[QSIZE];
	uint8_t in = 0;
	uint8_t out = 0;

	command void TweetQueue.add_tweet(tinyblog_t *tweet){
		memcpy(tweetStore[in].msg, tweet->data, tweet->nchars);
		tweetStore[in].nchars = tweet->nchars;
		tweetStore[in].sourceMoteID = tweet->sourceMoteID;
		tweetStore[in].mood = tweet->mood;
		tweetStore[in].seqno = tweet->seqno;
		in = (in + 1) % QSIZE;
	}
	command Tweet * TweetQueue.pop_tweet(){
		Tweet *t = &tweetStore[out];
		out = (out + 1) % QSIZE;
		return t;
	}
	 command bool TweetQueue.has_tweets(){
	 	return !(in == out);
	 }
}
