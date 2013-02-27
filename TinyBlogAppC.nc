


configuration TinyBlogAppC { }
implementation
{
  components TinyBlogC, MainC, ActiveMessageC, LedsC, TweetQueueC, PktBufferC, CircularQC,
    PrintfC, SerialStartC,
    new TimerMilliC(), 
    new TimerMilliC() as LEDTimer0,
    new TimerMilliC() as LEDTimer1,
    new TimerMilliC() as LEDTimer2,
    new HamamatsuS10871TsrC() as Sensor, 
    new AMSenderC(AM_TINYBLOGMSG), new AMReceiverC(AM_TINYBLOGMSG);

  TinyBlogC.Boot -> MainC;
  TinyBlogC.RadioControl -> ActiveMessageC;
  TinyBlogC.AMSend -> AMSenderC;
  TinyBlogC.Receive -> AMReceiverC;
  TinyBlogC.Timer -> TimerMilliC;
  TinyBlogC.LEDTimer0 -> LEDTimer0;
  TinyBlogC.LEDTimer1 -> LEDTimer1;
  TinyBlogC.LEDTimer2 -> LEDTimer2;
  TinyBlogC.Read -> Sensor;
  TinyBlogC.Leds -> LedsC;
  TinyBlogC.TweetQueue -> TweetQueueC;
  TinyBlogC.PktBuffer -> PktBufferC;
  TinyBlogC.FollowList -> CircularQC;

  
}
