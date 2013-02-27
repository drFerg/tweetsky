module TweetQueueC {
	provides interface TweetQueue;
}

implementation{
	command void TweetQueue.add_tweet(tinyblog_t *tweet){}
	command void TweetQueue.get_tweets(){}
}
