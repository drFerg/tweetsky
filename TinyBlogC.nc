#include <string.h>
#include <stdlib.h>
#include "Timer.h"
#include "TinyBlogMsg.h"
#include "printf.h"
#include "TweetQueue.h"

#define BASE 0
#define DEFAULT_INTERVAL 2500

module TinyBlogC @safe()
{
    uses {
        interface Boot;
        interface SplitControl as RadioControl;
        interface AMSend;
        interface Receive;
        interface Timer<TMilli>;
        interface Timer<TMilli> as MoodTimer;
        interface Timer<TMilli> as LEDTimer0;
        interface Timer<TMilli> as LEDTimer1;
        interface Timer<TMilli> as LEDTimer2;
        interface Read<uint16_t> as LightSensor;
        interface Read<uint16_t> as TempSensor;
        interface Leds;
        interface TweetQueue;
        interface PktBuffer;
        interface CircularQ as FollowList;
    }
}
implementation
{
    bool sendBusy = FALSE;
    bool moreTweets = FALSE;
    message_t am_pkt;
    tinyblog_t local;
    nx_uint8_t temp;
    nx_uint8_t light;
  

/*-----------LED Commands------------------------------- */
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
/*------------------------------------------------------- */

/*-----------Reports------------------------------- */
  // Use LEDs to report various status issues.
    void report_forward(){pulse_red_led(500);}
    void report_post_tweet(){printf("ID: %d, Posted tweet\n",TOS_NODE_ID);printfflush();pulse_green_led(500);}
    void report_fetch_tweet(){printf("ID: %d, Fetched tweet\n",TOS_NODE_ID);printfflush();pulse_blue_led(500);}

    void report_problem() { call Leds.led1Toggle(); }
    void report_sent() {pulse_green_led(100);}
    void report_received() {printf("ID: %d, Received tweet\n",TOS_NODE_ID);printfflush();pulse_red_led(100);pulse_blue_led(100);}
    void report_dropped(){printf("ID: %d, Dropped tweet\n----------\n",TOS_NODE_ID);printfflush();pulse_red_led(250);}
      
/*------------------------------------------------- */

    void send(tinyblog_t *tbmsg, int dest){
        tinyblog_t * payload = (tinyblog_t *) (call AMSend.getPayload(&am_pkt, sizeof(tinyblog_t)));
        memcpy(payload, tbmsg, sizeof(tinyblog_t));
        if (call AMSend.send(dest, &am_pkt, sizeof(tinyblog_t)) == SUCCESS)
            sendBusy = TRUE;
        if (!sendBusy)
            report_problem();
        printf("ID: %d, Tweet sent\n",TOS_NODE_ID);printfflush();
    }
/*----------------------------------------------------*/

    void add_user_to_follow(int user){
        //CHANGE TO DATA FIELD using bit manips
        call FollowList.push(user);
        printf("Added user: %d\n", user);
        printfflush();
    }


    void startMoodTimer() {
        call MoodTimer.startPeriodic(DEFAULT_INTERVAL);
    }
    void getMood(tinyblog_t *tbmsg){
        tbmsg->mood = (light<<16) + temp;
        printf("%d, %d, %d\n", light, temp, tbmsg->mood);printfflush();

    }
  
    bool tweet_for_me(tinyblog_t *tbmsg){
        if (tbmsg->destMoteID == TOS_NODE_ID){
            printf("ID: %d, Tweet for me\n",TOS_NODE_ID);
            return TRUE;
        } else return FALSE;
    }

    bool tweet_expired(tinyblog_t *tbmsg){
        if (tbmsg->hopCount == 0){

        dbg("Oh noes, packet's time to die");
        return TRUE;
        } else return FALSE;
    }

    bool tweet_seen(tinyblog_t *tbmsg){
        if (call PktBuffer.check(tbmsg)){

        dbg("Seen packet already");
        return TRUE;
        } else return FALSE;
    }

    void add_to_seen(tinyblog_t *tbmsg){
        printf("ID: %d, adding to blklist\n",TOS_NODE_ID);
        call PktBuffer.push(tbmsg);
    }
    bool am_following(tinyblog_t *tbmsg){
        return call FollowList.check(tbmsg->sourceMoteID);
    }
  
    void process_new_tweet(tinyblog_t *tbmsg){
        printf("ID: %d, Processing Tweet\n",TOS_NODE_ID);
        printf("ID: %d, Tweet from %d, seqno %d\n",TOS_NODE_ID, tbmsg->sourceMoteID, tbmsg->seqno);
        if (am_following(tbmsg)){
            call TweetQueue.add_tweet(tbmsg);
            printf("ID: %d, Saving Tweet(following id)\n",TOS_NODE_ID);
        } else printf("ID: %d, Not interested\n",TOS_NODE_ID);
        printfflush();
    }

    void send_my_tweet(tinyblog_t *tbmsg){
        //ADD SENSOR READING
        tbmsg->sourceMoteID = TOS_NODE_ID;
        tbmsg->destMoteID = 0;
        getMood(tbmsg);
    }


    void send_tweets_to_base(){
        Tweet *tweet;
        if (call TweetQueue.has_tweets()){
            tweet = call TweetQueue.pop_tweet(); /* Send tweet to base station */
            local.seqno = tweet->seqno;
            local.sourceMoteID = tweet->sourceMoteID;
            local.destMoteID = BASE;
            local.action = RETURN_TWEETS;
            local.hopCount = 6; //D of Web
            local.nchars = tweet->nchars;
            local.mood = tweet->mood;
            memcpy((char *)&(local.data), tweet->msg, tweet->nchars);
            send(&local, BASE);
            printf("Forwarding to base\n");
            printfflush();

            if (call TweetQueue.has_tweets())
                moreTweets = TRUE;
             else 
                moreTweets = FALSE;
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
        startMoodTimer();
    }

    event void RadioControl.stopDone(error_t error) {}

/*-----------Received packet event, main state event ------------------------------- */
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        tinyblog_t *tweet = (tinyblog_t *) payload;
        bool myTweet;
        report_received();
        myTweet =  tweet_for_me(tweet);
        

    /* Check if tweet is new, drop old tweets, stop broadcast storm */
        if (tweet_seen(tweet)){
            report_dropped();
            return msg;
        }

    /* Process tweet as it's new! */
        switch(tweet->action){
            case POST_TWEET: (myTweet?send_my_tweet(tweet):process_new_tweet(tweet));break;
            case GET_TWEETS: send_tweets_to_base(); break;
            case ADD_USER  : add_user_to_follow(tweet->destMoteID); return msg;
            default:break;
        }

    /* Tweet processed, check if end of line and forward */
        
        if (tweet_expired(tweet)){
            report_dropped();
        } else {
            send(tweet, AM_BROADCAST_ADDR);
            add_to_seen(tweet);
        }
        
         printf("----------\n");printfflush();
        return msg; /* Return packet to TinyOS */
        
    }

    event void AMSend.sendDone(message_t* msg, error_t error) {
        if (error == SUCCESS)
            report_sent();
        else
            report_problem();

        sendBusy = FALSE;
        if (moreTweets){
            send_tweets_to_base();
        }
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
/*-----------Mood Timer EVENT------------------------------- */    
    event void MoodTimer.fired(){
        if (call LightSensor.read() != SUCCESS)
            report_problem();
        if (call TempSensor.read() != SUCCESS)
            report_problem();
    }
/*-----------LED Timer EVENTS------------------------------- */
    event void LEDTimer1.fired(){
        call Leds.led2Toggle();
    }

    event void LEDTimer0.fired(){
        call Leds.led0Toggle();
    }
    event void LEDTimer2.fired(){
        call Leds.led1Toggle();
    }
/*-----------Sensor Events------------------------------- */
    event void LightSensor.readDone(error_t result, uint16_t data) {
        if (result != SUCCESS){
            data = 0xffff;
            report_problem();
        }
        light = data;
    }
    event void TempSensor.readDone(error_t result, uint16_t data) {
        if (result != SUCCESS){
            data = 0xffff;
            report_problem();
        }
        temp = data;
    }
}
