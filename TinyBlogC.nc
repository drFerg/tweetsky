#include <string.h>
#include <stdlib.h>
#include "Timer.h"
#include "TinyBlogMsg.h"

#include "TweetQueue.h"

#define BASE 0
#define DEFAULT_INTERVAL 2500

#if DEBUG
#include "printf.h"
#define PRINTF(...) printf(__VA_ARGS__)
#define PRINTFFLUSH(...) printfflush()
#else
#define PRINTF(...)
#define PRINTFFLUSH(...)
#endif

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
    #ifdef SCEN==2
    bool moreFollowees = FALSE;
    #endif
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
    void report_post_tweet(){PRINTF("ID: %d, Posted tweet\n",TOS_NODE_ID);PRINTFFLUSH();pulse_green_led(500);}
    void report_fetch_tweet(){PRINTF("ID: %d, Fetched tweet\n",TOS_NODE_ID);PRINTFFLUSH();pulse_blue_led(500);}

    void report_problem() { pulse_red_led(500);pulse_blue_led(500);pulse_green_led(500); }
    void report_sent() {pulse_green_led(100);}
    void report_received() {PRINTF("ID: %d, Received tweet\n",TOS_NODE_ID);PRINTFFLUSH();pulse_red_led(100);pulse_blue_led(100);}
    void report_dropped(){PRINTF("ID: %d, Dropped tweet\n----------\n",TOS_NODE_ID);PRINTFFLUSH();pulse_red_led(250);}
      
/*------------------------------------------------- */
    bool tweet_seen(tinyblog_t *tbmsg){
        if (call PktBuffer.check(tbmsg)){

        return TRUE;
        } else return FALSE;
    }

    void add_to_seen(tinyblog_t *tbmsg){
        PRINTF("ID: %d, adding to blklist\n",TOS_NODE_ID);
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
        PRINTF("ID: %d, Tweet sent to: %d from: %d\n",TOS_NODE_ID, dest, tbmsg->sourceMoteID);PRINTFFLUSH();
    }
/*----------------Timers----------------------------*/
    void startTimer(){
        call Timer.startPeriodic(DEFAULT_INTERVAL);
    }
    void startMoodTimer() {
        call MoodTimer.startPeriodic(DEFAULT_INTERVAL);
    }

/*------------Helper function-------------------------------*/
    void add_user_to_follow(int user){
        //CHANGE TO DATA FIELD using bit manips
        call FollowList.push(user);
        PRINTF("Added user: %d\n", user);
        PRINTFFLUSH();
    }

    void getMood(tinyblog_t *tbmsg){
        tbmsg->mood = (temp<<16) + light;
        PRINTF("%d, %d, %d\n", light, temp, tbmsg->mood);PRINTFFLUSH();

    }
  
    bool tweet_for_me(tinyblog_t *tbmsg){
        if (tbmsg->destMoteID == TOS_NODE_ID){
            PRINTF("ID: %d, Tweet for me\n",TOS_NODE_ID);
            return TRUE;
        } else return FALSE;
    }

    bool tweet_expired(tinyblog_t *tbmsg){
        if (tbmsg->hopCount == 0){
        return TRUE;
        } else return FALSE;
    }

    bool am_following(tinyblog_t *tbmsg){
        return call FollowList.check(tbmsg->sourceMoteID);
    }
/*---------------Direct message--------------------------------*/

    void send_direct_msg(tinyblog_t *tbmsg){
        tbmsg->sourceMoteID = TOS_NODE_ID;
        send(tbmsg,tbmsg->destMoteID);
    }
    void receive_direct_msg(tinyblog_t *tbmsg){
        PRINTF("Received a direct message from: %d\n", tbmsg->sourceMoteID);
        PRINTFFLUSH();
        tbmsg->destMoteID = BASE;
        send(tbmsg,BASE);
    }


/*------------------------------------------------------*/
    void process_new_tweet(tinyblog_t *tbmsg){
        PRINTF("ID: %d, Processing Tweet\n",TOS_NODE_ID);
        PRINTF("ID: %d, Tweet from %d, seqno %d\n",TOS_NODE_ID, tbmsg->sourceMoteID, tbmsg->seqno);
        if (am_following(tbmsg)){
            call TweetQueue.add_tweet(tbmsg);
            tbmsg->destMoteID = BASE;
            tbmsg->action = RETURN_TWEETS;
            send(tbmsg, BASE);
            PRINTF("ID: %d, Saving Tweet(following id)\n",TOS_NODE_ID);
        } else PRINTF("ID: %d, Not interested\n",TOS_NODE_ID);
        PRINTFFLUSH();
    }

    void send_my_tweet(tinyblog_t *tbmsg){
        //ADD SENSOR READING
        tbmsg->sourceMoteID = TOS_NODE_ID;
        tbmsg->destMoteID = 0;
        getMood(tbmsg);
    }

#if SCEN==1
    void copy_tweet_from_store_to_local(){
        Tweet *tweet;
        if (call TweetQueue.has_tweets()){
            tweet = call TweetQueue.pop_tweet(); /* Send tweet to base station */
            local.seqno = tweet->seqno;
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
        PRINTF("Forwarding to base\n");
        PRINTFFLUSH();

        if (call TweetQueue.has_tweets())
            moreTweets = TRUE;
         else 
            moreTweets = FALSE;
    
    }
#elif SCEN==2
    void copy_tweet_from_store_to_local(bool start){
        Tweet *tweet;
        if (start){
            call TweetQueue.createIterator();
        }
        tweet = call TweetQueue.iterate();
        if (tweet){ /* Send tweet to base station */
            local.seqno++;
            local.sourceMoteID = tweet->sourceMoteID;
            local.hopCount = 6; //D of Web
            local.nchars = tweet->nchars;
            local.mood = tweet->mood;
            memcpy((char *)&(local.data), tweet->msg, tweet->nchars);
            moreTweets = TRUE;
        } else{
            moreTweets = FALSE;
        }
    }
#endif
    

    


#if SCEN == 2
    void save_tweet(tinyblog_t *tbmsg){
        PRINTF("SAVED TWEET\n");
        PRINTFFLUSH();
        tbmsg->sourceMoteID = TOS_NODE_ID;
        call TweetQueue.add_tweet(tbmsg);
    }

    void send_tweet_event(bool start){
        copy_tweet_from_store_to_local(start);
        local.action = POST_TWEET;
        PRINTF("Tweet: seqno: %d\n",local.seqno);PRINTFFLUSH();
        send(&local, local.destMoteID);
    }

    void process_interest(tinyblog_t *tbmsg){
        int id = call InterestCache.getSender(tbmsg->destMoteID);
        if (tbmsg->destMoteID == TOS_NODE_ID){
            local.destMoteID = tbmsg->sourceMoteID;
            call InterestCache.push(tbmsg->destMoteID, tbmsg->sourceMoteID);
            send_tweet_event(TRUE);
            PRINTF("Forwarding to sink: %d\n", tbmsg->sourceMoteID);
            
        }
        else if (id){
            /* if an interest already exists for the user
             * refresh it */
            call InterestCache.refresh(tbmsg->destMoteID, id);
            PRINTF("Refreshed interest\n");
        }
        else { /* add interest to cache */
            call InterestCache.push(tbmsg->destMoteID, tbmsg->sourceMoteID);
            PRINTF("Added interest to cache\n");
        }
        tbmsg->sourceMoteID = TOS_NODE_ID;
        PRINTFFLUSH();
    }


    void process_tweet_event(tinyblog_t *tbmsg){
        int id = call InterestCache.getSender(tbmsg->sourceMoteID);
        if (id && id == TOS_NODE_ID){
            PRINTF("Tweet event for me\n");PRINTFFLUSH();
            tbmsg->action = RETURN_TWEETS;
            send(tbmsg, BASE);
            
        } else if (id && id != TOS_NODE_ID){
            PRINTF("Found route in cache\n");PRINTFFLUSH();
            tbmsg->destMoteID = id;
            send(tbmsg,id);
        }
        else {
            PRINTF("No valid route for event\n");PRINTFFLUSH();
            report_dropped();
        }
    }

    void send_interest(bool start){
        int followee;
        if (start){
            PRINTF("Creating iterator\n");
            call FollowList.createIterator();
        }
        followee = call FollowList.iterate();
        if (followee == -1){ // No more followees
            moreFollowees = FALSE;
            PRINTF("End of follow list\n");
        }
        else{ //Someone to follow
            
            int id = call InterestCache.getSender(followee);
            PRINTF("Creating interest...");
            if (id == TOS_NODE_ID){ // if user has already asked, refresh
                call InterestCache.refresh(followee, id);
            }
            else { //user hasn't asked, create new interest
                call InterestCache.push(followee, TOS_NODE_ID);
            }
            local.seqno++;
            local.sourceMoteID = TOS_NODE_ID;
            local.destMoteID = followee;
            local.action = GET_TWEETS;
            // create msg to broadcast out
            PRINTF("done\n");
            send(&local,AM_BROADCAST_ADDR);
            moreFollowees = TRUE;
        }
        
        PRINTFFLUSH();
    }

#endif




    
/*************************************************************/
/***********EVENTS********************************************/
    event void Boot.booted() {
        if (call RadioControl.start() != SUCCESS) report_problem();
        local.seqno = 0;
        PRINTF("*********************\n****** BOOTED *******\n*********************\n");
        PRINTFFLUSH();
        

    }
/*-----------Radio & AM EVENTS------------------------------- */
    event void RadioControl.startDone(error_t error) {
        startMoodTimer();
#if SCEN==2
        //startTimer();
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
            PRINTF("Already seen\n");PRINTFFLUSH();
            report_dropped();
            return msg;
        }
        PRINTF("TWEET FROM: %d to %d\n", tweet->sourceMoteID, tweet->destMoteID);
        PRINTFFLUSH();
#if SCEN == 1
            
    /* Process tweet as it's new! */
        switch(tweet->action){
            case POST_TWEET: (myTweet?send_my_tweet(tweet):process_new_tweet(tweet));break;
            case GET_TWEETS: send_tweets_to_base();return msg;
            case ADD_USER  : add_user_to_follow(tweet->data[0]); return msg;
            case DIRECT_MESSAGE: (myTweet?receive_direct_msg(tweet):send_direct_msg(tweet));return msg;
            default:break;
        }
        /* Tweet processed, check if end of line and forward */
        if (tweet_expired(tweet)){
            PRINTF("Expired\n");
            report_dropped();
        } else {
            send(tweet, AM_BROADCAST_ADDR);
        }
        

#elif SCEN == 2
        /* Tweet possibly already seen as interest */
        id = call InterestCache.getSender(tweet->destMoteID);
        if (id > 0)
                tweet->sourceMoteID = id;
    /* Process tweet as it's new! */
        
        switch(tweet->action){
            case POST_TWEET: (fromBase?save_tweet(tweet):process_tweet_event(tweet));return msg;break;
            case GET_TWEETS: 
                if (fromBase){
                    send_interest(TRUE);
                }else if (!tweet_seen(tweet)){
                    process_interest(tweet);
                }else report_dropped();
                break;
            case ADD_USER  : add_user_to_follow(tweet->data[0]); return msg;
            default:break;
        }

#endif
    
        
        
         PRINTF("----------\n");PRINTFFLUSH();
        return msg; /* Return packet to TinyOS */
        
    }

    event void AMSend.sendDone(message_t* msg, error_t error) {
        if (error == SUCCESS)
            report_sent();
        else
            report_problem();

        sendBusy = FALSE;
        #if SCEN==1
        if (moreTweets){
            send_tweets_to_base();
        }
        #elif SCEN==2
        if (moreTweets){
            send_tweet_event(FALSE);
        }
        /* Are there any more interests(get tweets) to send? */
        if (moreFollowees){
            send_interest(FALSE);
        }
        #endif

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
            PRINTF("ID: %d, Built tweet, %d\n",TOS_NODE_ID, tweet->seqno-1);
            if (call AMSend.send(AM_BROADCAST_ADDR, &am_pkt, sizeof(tinyblog_t)) == SUCCESS){
                sendBusy = TRUE;
            }
        }
        PRINTF("ID: %d, Sent tweet\n",TOS_NODE_ID);PRINTFFLUSH();

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
        if (TOS_NODE_ID == 3){
            call InterestCache.push(8, TOS_NODE_ID);
            local.sourceMoteID = TOS_NODE_ID;
            local.destMoteID = 8;
            local.action = GET_TWEETS;
            send(&local, AM_BROADCAST_ADDR);
        }


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
