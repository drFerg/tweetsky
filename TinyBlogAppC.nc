


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

        components new TimerMilliC(), 
        new TimerMilliC() as MoodTimer,
        new TimerMilliC() as LEDTimer0,
        new TimerMilliC() as LEDTimer1,
        new TimerMilliC() as LEDTimer2,
        #if TELOS
        new HamamatsuS10871TsrC() as LightSensor,
        new SensirionSht11C().Temperature as TempSensor,
        #else
        new DemoSensorC() as LSensor,
        new DemoSensorC() as TSensor,
        #endif
        new AMSenderC(AM_TINYBLOGMSG), new AMReceiverC(AM_TINYBLOGMSG);
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
    TinyBlogC.TempSensor -> TempSensor;
    TinyBlogC.Leds -> LedsC;
    TinyBlogC.TweetQueue -> TweetQueueC;
    TinyBlogC.PktBuffer -> PktBufferC;
    TinyBlogC.FollowList -> CircularQC;
    #if SCEN==2
    TinyBlogC.InterestCache -> InterestTableC;
    TinyBlogC.InterestTimer -> InterestTimer;
    #endif

  
}
