


configuration TinyBlogAppC { }
implementation
{
    components TinyBlogC, MainC, ActiveMessageC, LedsC, SerialStartC,
        TweetQueueC, 
        PktBufferC, 
        CircularQC;
    #if DEBUG
    components PrintfC;
    #endif
/* Timers */
        components new TimerMilliC(), 
        new TimerMilliC() as MoodTimer,
        new TimerMilliC() as LEDTimer0,
        new TimerMilliC() as LEDTimer1,
        new TimerMilliC() as LEDTimer2;
/* Sensors */
        #if TELOS
        components new HamamatsuS10871TsrC() as LightSensor,
        new SensirionSht11C() as TempSensor;
        #else
        components new DemoSensorC() as LightSensor,
        new DemoSensorC() as TempSensor;
        #endif
/* Radio/Security */
        #if SECURE
        components new SecAMSenderC(AM_TINYBLOGMSG) as AMSenderC;
        components CC2420KeysC;
        #else
        components new AMSenderC(AM_TINYBLOGMSG);
        #endif
        components new AMReceiverC(AM_TINYBLOGMSG);
/* Scenario 2 */
        #if SCEN==2 
        components InterestTableC, new TimerMilliC() as InterestTimer;
        #endif


    TinyBlogC.Boot -> MainC;
    TinyBlogC.RadioControl -> ActiveMessageC;
    TinyBlogC.AMSend -> AMSenderC;
    TinyBlogC.Receive -> AMReceiverC;
    TinyBlogC.Timer -> TimerMilliC;
    TinyBlogC.MoodTimer -> MoodTimer;
    TinyBlogC.LEDTimer0 -> LEDTimer0;
    TinyBlogC.LEDTimer1 -> LEDTimer1;
    TinyBlogC.LEDTimer2 -> LEDTimer2;
    TinyBlogC.LightSensor -> LightSensor;
    #if TELOS
    TinyBlogC.TempSensor -> TempSensor.Temperature;
    #else 
    TinyBlogC.TempSensor -> TempSensor;
    #endif
    TinyBlogC.Leds -> LedsC;
    TinyBlogC.TweetQueue -> TweetQueueC;
    TinyBlogC.PktBuffer -> PktBufferC;
    TinyBlogC.FollowList -> CircularQC;
    #if SCEN==2
    TinyBlogC.InterestCache -> InterestTableC;
    TinyBlogC.InterestTimer -> InterestTimer;
    #endif

    #if SECURE
    TinyBlogC.CC2420Security -> AMSenderC;
    TinyBlogC.CC2420Keys -> CC2420KeysC;
    #endif
  
}
