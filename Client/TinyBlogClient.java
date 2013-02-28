/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;

/* The "Oscilloscope" demo app. Displays graphs showing data received from
   the Oscilloscope mote application, and allows the user to:
   - zoom in or out on the X axis
   - set the scale on the Y axis
   - change the sampling period
   - change the color of each mote's graph
   - clear all data

   This application is in three parts:
   - the Node and Data objects store data received from the motes and support
     simple queries
   - the Window and Graph and miscellaneous support objects implement the
     GUI and graph drawing
   - the Oscilloscope object talks to the motes and coordinates the other
     objects

   Synchronization is handled through the Oscilloscope object. Any operation
   that reads or writes the mote data must be synchronized on Oscilloscope.
   Note that the messageReceived method below is synchronized, so no further
   synchronization is needed when updating state based on received messages.
*/
public class TinyBlogClient implements MessageListener
{
    MoteIF mote;


    /* Main entry point */
    void run() {

        mote = new MoteIF(PrintStreamMessenger.err);
        mote.registerListener(new TinyBlogMsg(), this);
        System.out.println("hello world");
    }

    /* The data object has informed us that nodeId is a previously unknown
       mote. Update the GUI. */


    public synchronized void messageReceived(int dest_addr, 
            Message msg) {
    if (msg instanceof TinyBlogMsg) {
        TinyBlogMsg tbmsg = (TinyBlogMsg)msg;
        System.out.println(tbmsg.get_sourceMoteID());
        /* Update interval and mote data */
        
        /* Inform the GUI that new data showed up */
        }
    }

    /* The user wants to set the interval to newPeriod. Refuse bogus values
       and return false, or accept the change, broadcast it, and return
       true */

    /* Broadcast a version+interval message. */
    void sendMsg() {
        TinyBlogMsg tbmsg = new TinyBlogMsg();

        tbmsg.set_sourceMoteID(0);
        tbmsg.set_destMoteID(3);
        try {
            mote.send(MoteIF.TOS_BCAST_ADDR, tbmsg);
        }
        catch (IOException e) {
            //System.err.out("Cannot send message to mote");
        }
    }

    /* User wants to clear all data. */


    public static void main(String[] args) {
        TinyBlogClient me = new TinyBlogClient();
        me.run();
    }
}
