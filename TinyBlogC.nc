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
        #if SCEN==2
        interface InterestTable as InterestCache;
        interface Timer<TMilli> as InterestTimer;
        #endif
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


    void send(tinyblog_t *tbmsg, int dest){
        tinyblog_t * payload = (tinyblog_t *) (call AMSend.getPayload(&am_pkt, sizeof(tinyblog_t)));
        memcpy(payload, tbmsg, sizeof(tinyblog_t));
        if (call AMSend.send(dest, &am_pkt, sizeof(tinyblog_t)) == SUCCESS)
            sendBusy = TRUE;
        if (!sendBusy)
            report_problem();
        add_to_seen(tbmsg);
        printf("ID: %d, Tweet sent to: %d from: %d\n",TOS_NODE_ID, dest, tbmsg->sourceMoteID);printfflush();
    }
/*----------------------------------------------------*/

    void add_user_to_follow(int user){
        //CHANGE TO DATA FIELD using bit manips
        call FollowList.push(user);
        printf("Added user: %d\n", user);
        printfflush();
    }

    void startTimer(){
        call Timer.startPeriodic(DEFAULT_INTERVAL);
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
    void copy_tweet_from_store_to_local(){
        Tweet *tweet;
        if (call TweetQueue.has_tweets()){
            tweet = call TweetQueue.pop_tweet(); /* Send tweet to base station */
            local.seqno = tweet->seqno++;
            local.sourceMoteID = tweet->sourceMoteID;
            local.hopCount = 6; //D of Web
            local.nchars = tweet->nchars;
            local.mood = tweet->mood;
            memcpy((char *)&(local.data), tweet->msg, tweet->nchars);
        }
    }

    void send_tweets_to_base(){
        copy_tweet_from_store_to_local();
        local.destMoteID = BASE;
        local.action = RETURN_TWEETS;
        send(&local, BASE);
        printf("Forwarding to base\n");
        printfflush();

        if (call TweetQueue.has_tweets())
            moreTweets = TRUE;
         else 
            moreTweets = FALSE;
    
    }

    


#if SCEN == 2
    void save_tweet(tinyblog_t *tbmsg){
        call TweetQueue.add_tweet(tbmsg);
    }

    void process_interest(tinyblog_t *tbmsg){
        int id = call InterestCache.getSender(tbmsg->destMoteID);
        if (tbmsg->destMoteID == TOS_NODE_ID){
            copy_tweet_from_store_to_local();
            local.action = POST_TWEET;
            local.destMoteID = tbmsg->sourceMoteID;
            send(&local, tbmsg->sourceMoteID);
            call InterestCache.push(tbmsg->destMoteID, tbmsg->sourceMoteID);
            printf("Forwarding to sink: %d\n", tbmsg->sourceMoteID);
            
        }
        else if (id){
            /* if an interest already exists for the user
             * refresh it */
            call InterestCache.refresh(tbmsg->destMoteID, id);
            printf("Refreshed interest\n");
        }
        else { /* add interest to cache */
            call InterestCache.push(tbmsg->destMoteID, tbmsg->sourceMoteID);
            printf("Added interest to cache\n");
        }
        tbmsg->sourceMoteID = TOS_NODE_ID;
        printfflush();
    }


    void process_tweet_event(tinyblog_t *tbmsg){
        int id = call InterestCache.getSender(tbmsg->sourceMoteID);
        if (id && id != TOS_NODE_ID){
            printf("HELLO\n");printfflush();
            tbmsg->destMoteID = id;
            send(tbmsg,id);
        } else if (id == TOS_NODE_ID){
            printf("GOT A RESPONSE, LIKE A BOSS\n");
            tbmsg->action = RETURN_TWEETS;
            send(tbmsg, BASE);
        }
        else {
            printf("No valid route for event\n");
            report_dropped();
        }
    }

    void send_interest(tinyblog_t *tbmsg){
        int id = call InterestCache.getSender(5);
        printf("Creating interest...");
        if (id == TOS_NODE_ID){
            call InterestCache.refresh(5, id);
        }
        else {
            call InterestCache.push(5, TOS_NODE_ID);
        }

        tbmsg->sourceMoteID = TOS_NODE_ID;
        tbmsg->destMoteID = 5;
        tbmsg->action = GET_TWEETS;
        printf("done\n");printfflush();
    }

#endif




    

/***********EVENTS********************************************/
    event void Boot.booted() {
        if (call RadioControl.start() != SUCCESS) report_problem();
        local.seqno = 0;
        add_user_to_follow(3);
    }
/*-----------Radio & AM EVENTS------------------------------- */
    event void RadioControl.startDone(error_t error) {
        startMoodTimer();
#if SCEN==2
        startTimer();
#endif
    }

    event void RadioControl.stopDone(error_t error) {}

/*-----------Received packet event, main state event ------------------------------- */
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        tinyblog_t *tweet = (tinyblog_t *) payload;
        bool fromBase = tweet->sourceMoteID == BASE;
        bool myTweet;
        int id;
        report_received();
        myTweet =  tweet_for_me(tweet);
        /* Check if tweet is new, drop old tweets, stop broadcast storm */
        if (tweet_seen(tweet)){
            report_dropped();
            return msg;
        }
        printf("TWEET FROM: %d to %d\n", tweet->sourceMoteID, tweet->destMoteID);
        printfflush();
#if SCEN == 1
            
    /* Process tweet as it's new! */
        switch(tweet->action){
            case POST_TWEET: (myTweet?send_my_tweet(tweet):process_new_tweet(tweet));break;
            case GET_TWEETS: send_tweets_to_base();return msg;
            case ADD_USER  : add_user_to_follow(tweet->data[0]); return msg;
            default:break;
        }


#elif SCEN == 2
        id = call InterestCache.getSender(tweet->destMoteID);
        if (id > 0)
                tweet->sourceMoteID = id;
        if (fromBase || !tweet_seen(tweet)){
/* Process tweet as it's new! */
        
            switch(tweet->action){
                case POST_TWEET: (fromBase?save_tweet(tweet):process_tweet_event(tweet));return msg;break;
                case GET_TWEETS: (fromBase?send_interest(tweet):process_interest(tweet));break;
                case ADD_USER  : add_user_to_follow(tweet->data[0]); return msg;
                default:break;
            }
        }
        else {
            report_dropped();
            return msg;
        }
#endif
    /* Tweet processed, check if end of line and forward */
        
        if (tweet_expired(tweet)){
            report_dropped();
        } else {
            send(tweet, AM_BROADCAST_ADDR);
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
#if SCEN==1
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
#elif SCEN==2

        local.sourceMoteID = TOS_NODE_ID;
        local.destMoteID = 0;
        local.action = POST_TWEET;
        local.hopCount = 6; //D of Web
        local.nchars = 14;
        local.seqno++;
        strcpy((char *)&local.data,"Hello, world!");
        local.mood = 0;
        save_tweet(&local);

        call InterestCache.push(5, TOS_NODE_ID);
        local.sourceMoteID = TOS_NODE_ID;
        local.destMoteID = 5;
        local.action = GET_TWEETS;
        send(&local, AM_BROADCAST_ADDR);


#endif
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


/*---------Interest Expiry Timer Event--------------------*/

#if SCEN==2
    event void InterestTimer.fired(){
        call InterestCache.expireInterests();
    }
#endif
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
