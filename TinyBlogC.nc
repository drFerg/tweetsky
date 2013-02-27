#include <string.h>
#include <stdlib.h>
#include "Timer.h"
#include "TinyBlogMsg.h"
#include "printf.h"

#define DEFAULT_INTERVAL 5000

module TinyBlogC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Timer<TMilli> as LEDTimer0;
    interface Timer<TMilli> as LEDTimer1;
    interface Timer<TMilli> as LEDTimer2;
    interface Read<uint16_t>;
    interface Leds;
    interface TweetQueue;
    interface PktBuffer;
    interface CircularQ as FollowList;
  }
}
implementation
{
  bool sendBusy;
  message_t am_pkt;
  tinyblog_t local;

  int seqno = 0;

  

  void pulse_green_led(int t){
    call Leds.led1Toggle();
    call LEDTimer2.startOneShot(t);
  }

  void pulse_red_led(int t){
    call Leds.led0Toggle();
    call LEDTimer0.startOneShot(t);
  }

  void pulse_blue_led(int t){
    call Leds.led2Toggle();
    call LEDTimer1.startOneShot(t);
  }


  int get_mood(){
    return 0;
  }

  // Use LEDs to report various status issues.
  void report_forward(){pulse_red_led(500);}
  void report_post_tweet(){printf("ID: %d, Posted tweet\n",TOS_NODE_ID);printfflush();pulse_green_led(500);}
  void report_fetch_tweet(){printf("ID: %d, Fetched tweet\n",TOS_NODE_ID);printfflush();pulse_blue_led(500);}

  void report_problem() { call Leds.led1Toggle(); }
  void report_sent() {pulse_green_led(100);}
  void report_received() {printf("----------\nID: %d, Received tweet\n",TOS_NODE_ID);printfflush();pulse_red_led(100);pulse_blue_led(100);}
  void report_dropped(){printf("ID: %d, Dropped tweet\n----------\n",TOS_NODE_ID);printfflush();pulse_red_led(250);}
  

  event void LEDTimer1.fired(){
    call Leds.led2Toggle();
  }

  event void LEDTimer0.fired(){
    call Leds.led0Toggle();
  }
  event void LEDTimer2.fired(){
    call Leds.led1Toggle();
  }
void add_user_to_follow(int user){
    //CHANGE TO DATA FIELD using bit manips
    call FollowList.push(user);
  }



  event void Boot.booted() {
    if (call RadioControl.start() != SUCCESS)
      report_problem();
    add_user_to_follow(3);
  }

  void startTimer() {
    call Timer.startPeriodic(DEFAULT_INTERVAL);
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {}

  int tweet_for_me(tinyblog_t *tweet){
     if (tweet->destMoteID == TOS_NODE_ID){
        dbg("This is my packet, thank you");
        return 1;
    } else return 0;
  }
  int tweet_expired(tinyblog_t *tweet){
    if (tweet->hopCount == 0){
      dbg("Oh noes, packet's time to die");
      return 1;
    } else return 0;
  }

  int tweet_seen(tinyblog_t *tweet){
    if (call PktBuffer.check(tweet)){
      dbg("Seen packet already");
      return 1;
    } else return 0;
  }

  void add_to_seen(tinyblog_t *tweet){
    call PktBuffer.push(tweet);
  }
  bool am_following(tinyblog_t *tweet){
    printf("ID: %d, Tweet from %d\n",TOS_NODE_ID, tweet->sourceMoteID);
    return call FollowList.check(tweet->sourceMoteID);
  }
  
  void process_new_tweet(tinyblog_t *tweet){
    printf("ID: %d, Processing Tweet\n",TOS_NODE_ID);
    if (am_following(tweet)){
     call TweetQueue.add_tweet(tweet);
     printf("ID: %d, Saving Tweet(following id)\n",TOS_NODE_ID);
    } else printf("ID: %d, Not interested\n",TOS_NODE_ID);
    printfflush();
  }

  void send(tinyblog_t *tweet){
    tinyblog_t * payload = (tinyblog_t *) (call AMSend.getPayload(&am_pkt, sizeof(tinyblog_t)));
    memcpy(payload, tweet, sizeof(tweet));
    if (call AMSend.send(AM_BROADCAST_ADDR, &am_pkt, sizeof(tinyblog_t)) == SUCCESS)
        sendBusy = TRUE;
    if (!sendBusy)
      report_problem();
    printf("ID: %d, Tweet Forwarded\n----------\n",TOS_NODE_ID);printfflush();
  }
  void send_tweets_to_base(){
    while (call TweetQueue.has_tweets()){
      call TweetQueue.pop_tweet(); /* Send tweet to base station */
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    tinyblog_t *tweet = payload;
    report_received();

    /* Check if tweet is new, drop old tweets, stop broadcast storm */
    if (tweet_seen(tweet)){
      report_dropped();
      return msg;
    } 
    else add_to_seen(tweet);

    /* Process tweet as it's new! */
    switch(tweet->action){
      case POST_TWEET: process_new_tweet(tweet);     break;
      case GET_TWEETS: send_tweets_to_base();        break;
      case ADD_USER  : add_user_to_follow(tweet->destMoteID);    break;
      default:break;
    }

    

    /* Tweet processed, check if end of line */
    if (tweet_expired(tweet)){
      report_dropped();
      return msg;
    } else send(tweet);

    return msg;
  }

  event void Timer.fired() {
    if (!sendBusy)
	  {
      tinyblog_t * tweet = (tinyblog_t *) (call AMSend.getPayload(&am_pkt, sizeof(tinyblog_t)));
      tweet->seqno = local.seqno++;
      tweet->sourceMoteID = TOS_NODE_ID;
      tweet->destMoteID = 0;
      tweet->action = POST_TWEET;
      tweet->hopCount = 6; //D of Web
      tweet->nchars = 14;
      strcpy((char *)tweet->data,"Hello, world!");
      tweet->mood = 0;
      add_to_seen(tweet);

	    if (call AMSend.send(AM_BROADCAST_ADDR, &am_pkt, sizeof(tinyblog_t)) == SUCCESS)
	      sendBusy = TRUE;
	  }
    printf("ID: %d, Sent tweet\n",TOS_NODE_ID);printfflush();

	  if (!sendBusy)
      report_problem();
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendBusy = FALSE;
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS){
	       data = 0xffff;
	       report_problem();
      }
    }
}
