


configuration TinyBlogAppC { }
implementation
{
    components TinyBlogC, MainC, ActiveMessageC, LedsC, PrintfC, SerialStartC,
        TweetQueueC, 
        PktBufferC, 
        CircularQC,

        new TimerMilliC(), 
        new TimerMilliC() as MTimer,
        new TimerMilliC() as LEDTimer0,
        new TimerMilliC() as LEDTimer1,
        new TimerMilliC() as LEDTimer2,
        new HamamatsuS10871TsrC() as LSensor,
        new SensirionSht11C() as TSensor,
        new AMSenderC(AM_TINYBLOGMSG), new AMReceiverC(AM_TINYBLOGMSG);
        #if SCEN==2 
        components InterestTableC, new TimerMilliC() as InterestTimer;
        #endif
    TinyBlogC.Boot -> MainC;
    TinyBlogC.RadioControl -> ActiveMessageC;
    TinyBlogC.AMSend -> AMSenderC;
    TinyBlogC.Receive -> AMReceiverC;
    TinyBlogC.Timer -> TimerMilliC;
    TinyBlogC.MoodTimer -> MTimer;
    TinyBlogC.LEDTimer0 -> LEDTimer0;
    TinyBlogC.LEDTimer1 -> LEDTimer1;
    TinyBlogC.LEDTimer2 -> LEDTimer2;
    TinyBlogC.LightSensor -> LSensor;
    TinyBlogC.TempSensor -> TSensor.Temperature;
    TinyBlogC.Leds -> LedsC;
    TinyBlogC.TweetQueue -> TweetQueueC;
    TinyBlogC.PktBuffer -> PktBufferC;
    TinyBlogC.FollowList -> CircularQC;
    #if SCEN==2
    TinyBlogC.InterestCache -> InterestTableC;
    TinyBlogC.InterestTimer -> InterestTimer;
    #endif

  
}
