GEN=TinyBlogMsg.java Constants.java
CFLAGS+= -DTOSH_DATA_LENGTH=112
all: tinyblogclient.jar

serial:
	java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB0:telosb &

tinyblogclient.jar: TinyBlogClient.class
	jar cf $@ *.class

TinyBlogMsg.java: ../TinyBlogMsg.h
	mig -target=null $(CFLAGS) -java-classname=TinyBlogMsg java ../TinyBlogMsg.h TinyBlogMsg -o $@

Constants.java: ../TinyBlogMsg.h
	ncg -target=null $(CFLAGS) -java-classname=Constants java ../TinyBlogMsg.h DIRECT_MESSAGE DATA_SIZE POST_TWEET ADD_USER GET_TWEETS INTEREST TWEET_EVENT -o $@


TinyBlogClient.class: $(wildcard *.java) $(GEN)
	javac *.java

clean:
	rm -f *.class $(GEN)

veryclean: clean
	rm tinyblogclient.jar
