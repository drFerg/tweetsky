
#include "Timer.h"
#include "TinyBlogMsg.h"

#define DEFAULT_INTERVAL 500

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
  }
}
implementation
{
  message_t sendBuf;
  bool sendBusy;

  int seqno = 0;

  /* Current local state - interval, version and accumulated readings */
  tinyblog_t local;

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
  void report_post_tweet(){pulse_green_led(500);}
  void report_fetch_tweet(){pulse_blue_led(500);}

  void report_problem() { call Leds.led1Toggle(); }
  void report_sent() {}
  void report_received() {}
  void report_dropped(){}
  

event void LEDTimer1.fired(){
  call Leds.led2Toggle();
}

event void LEDTimer0.fired(){
  call Leds.led0Toggle();
}
event void LEDTimer2.fired(){
  call Leds.led1Toggle();
}


  event void Boot.booted() {
    if (call RadioControl.start() != SUCCESS)
      report_problem();
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
  int am_following(tinyblog_t *tweet){
    return 1;
  }
  void add_user_to_follow(tinyblog_t *tweet){}
  void process_new_tweet(tinyblog_t *tweet){
    if (am_following(tweet)){
      //add_to_new_tweets(tweet);
    }
  }

  void send(tinyblog_t *tweet){

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
      case POST_TWEET: process_new_tweet(tweet); break;
      case GET_TWEETS: call TweetQueue.get_tweets();             break;
      case ADD_USER  : add_user_to_follow(tweet);break;
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
    if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  {
      local.seqno++;
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      sendBusy = TRUE;
	  }
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
