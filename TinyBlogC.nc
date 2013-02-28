#include <string.h>
#include <stdlib.h>
#include "Timer.h"
#include "TinyBlogMsg.h"
#include "printf.h"
#include "TweetQueue.h"
#define NEW_PRINTF_SEMANTICS

#define DEFAULT_INTERVAL 2500

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
      

  

    void add_user_to_follow(int user){
        //CHANGE TO DATA FIELD using bit manips
        call FollowList.push(user);
    }



 

    void startTimer() {
        call Timer.startPeriodic(DEFAULT_INTERVAL);
    }

  
    bool tweet_for_me(tinyblog_t *tweet){
        if (tweet->destMoteID == TOS_NODE_ID){
            printf("ID: %d, My tweet\n",TOS_NODE_ID);
            return TRUE;
        } else return FALSE;
    }

    bool tweet_expired(tinyblog_t *tweet){
        if (tweet->hopCount == 0){

        dbg("Oh noes, packet's time to die");
        return TRUE;
        } else return FALSE;
    }

    bool tweet_seen(tinyblog_t *tweet){
        if (call PktBuffer.check(tweet)){

        dbg("Seen packet already");
        return TRUE;
        } else return FALSE;
    }

    void add_to_seen(tinyblog_t *tweet){
        printf("ID: %d, adding to blklist\n",TOS_NODE_ID);
        call PktBuffer.push(tweet);
    }
    bool am_following(tinyblog_t *tweet){
        return call FollowList.check(tweet->sourceMoteID);
    }
  
    void process_new_tweet(tinyblog_t *tweet){
        printf("ID: %d, Processing Tweet\n",TOS_NODE_ID);
        printf("ID: %d, Tweet from %d, seqno %d\n",TOS_NODE_ID, tweet->sourceMoteID, tweet->seqno);
        if (am_following(tweet)){
            call TweetQueue.add_tweet(tweet);
            printf("ID: %d, Saving Tweet(following id)\n",TOS_NODE_ID);
        } else printf("ID: %d, Not interested\n",TOS_NODE_ID);
        printfflush();
    }

    void send(tinyblog_t *tweet){
        tinyblog_t * payload = (tinyblog_t *) (call AMSend.getPayload(&am_pkt, sizeof(tinyblog_t)));
        memcpy(payload, tweet, sizeof(tinyblog_t));
        if (call AMSend.send(AM_BROADCAST_ADDR, &am_pkt, sizeof(tinyblog_t)) == SUCCESS)
            sendBusy = TRUE;
        if (!sendBusy)
            report_problem();
        printf("ID: %d, Tweet Forwarded\n----------\n",TOS_NODE_ID);printfflush();
    }
    void send_tweets_to_base(){
        Tweet *tweet;
        while (call TweetQueue.has_tweets()){
            tweet = call TweetQueue.pop_tweet(); /* Send tweet to base station */
            printf("ID: %d, %s, src %d, seqno %d\n",TOS_NODE_ID, (char *)(tweet->msg), tweet->sourceMoteID, tweet->seqno);
            printfflush();
        }
    }


/***********EVENTS********************************************/




    event void Boot.booted() {
        if (call RadioControl.start() != SUCCESS) report_problem();
        local.seqno = 0;
        add_user_to_follow(3);
    }
/*-----------Radio & AM EVENTS------------------------------- */
    event void RadioControl.startDone(error_t error) {
        startTimer();
    }

    event void RadioControl.stopDone(error_t error) {}

/*-----------Received packet event, main state event ------------------------------- */
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        tinyblog_t *tweet = payload;
        report_received();

    /* Check if tweet is new, drop old tweets, stop broadcast storm */
        if (tweet_seen(tweet)){
            report_dropped();
            return msg;
        } else {
            add_to_seen(tweet);

        /* Process tweet as it's new! */
            switch(tweet->action){
                case POST_TWEET: process_new_tweet(tweet);     break;
                case GET_TWEETS: send_tweets_to_base();        break;
                case ADD_USER  : add_user_to_follow(tweet->destMoteID);    break;
                default:break;
            }

        /* Tweet processed, check if end of line and forward */
            if (tweet_expired(tweet)){
                report_dropped();
            } else {
                send(tweet);
            }

            return msg; /* Return packet to TinyOS */
        }
    }

    event void AMSend.sendDone(message_t* msg, error_t error) {
        if (error == SUCCESS)
            report_sent();
        else
            report_problem();

        sendBusy = FALSE;
    }

    event void Timer.fired() {
        if (!sendBusy){
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
            printf("ID: %d, Built tweet, %d\n",TOS_NODE_ID, tweet->seqno-1);
            if (call AMSend.send(AM_BROADCAST_ADDR, &am_pkt, sizeof(tinyblog_t)) == SUCCESS){
                sendBusy = TRUE;
            }
        }
        printf("ID: %d, Sent tweet\n",TOS_NODE_ID);printfflush();

        if (!sendBusy)
            report_problem();
        send_tweets_to_base();
    }
/*---------------------------------------------------- */


/*-----------LED EVENTS------------------------------- */
    event void LEDTimer1.fired(){
        call Leds.led2Toggle();
    }

    event void LEDTimer0.fired(){
        call Leds.led0Toggle();
    }
    event void LEDTimer2.fired(){
        call Leds.led1Toggle();
    }
/*-----------------------------------------------------*/
 
/*-----------Sensor Events------------------------------- */
    event void Read.readDone(error_t result, uint16_t data) {
        if (result != SUCCESS){
            data = 0xffff;
            report_problem();
        }
    }
}
