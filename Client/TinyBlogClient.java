import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;
import java.util.Scanner;


public class TinyBlogClient implements MessageListener
{
    MoteIF mote;
    int MOTEID = 5;
    short seqno = 0;

    private void cli(){
        Scanner input = new Scanner(System.in);
        String command = input.next();
        while (!command.equals("quit")){
            if (command.equals("tweet")){
                tweet(input.nextLine().trim());
            }
            command = input.next();
        }
    }

    /* Main entry point */
    void run() {
        mote = new MoteIF(PrintStreamMessenger.err);
        mote.registerListener(new TinyBlogMsg(), this);
        cli();
    }

    short[] convertStringToShort(String s){
        short [] text = new short[s.length()];
        for (int i = 0; i < s.length(); i++){
            text[i] = (new Integer(s.charAt(i))).shortValue();
        }
        return text;
    }

    String convertShortToString(short[] s){
        String text = "";
        for (int i = 0; i < s.length; i++){
            text += (char)s[i];
        }
        return text;
    }
    void tweet(String text){
        short[] data = convertStringToShort(text);
        short len = (short)data.length;


        System.out.println("Sending tweet...");
        TinyBlogMsg msg = new TinyBlogMsg();
        msg.set_action((short)1);
        msg.set_data(data);
        msg.set_nchars(len);
        System.out.println(text);
        sendMsg(msg);
    }


    public synchronized void messageReceived(int dest_addr, 
            Message msg) {
    if (msg instanceof TinyBlogMsg) {
        TinyBlogMsg tbmsg = (TinyBlogMsg)msg;
        if (tbmsg.get_sourceMoteID() != MOTEID)return;
        /* Update interval and mote data */
        
        /* Inform the GUI that new data showed up */
        }
    }

    /* The user wants to set the interval to newPeriod. Refuse bogus values
       and return false, or accept the change, broadcast it, and return
       true */

    /* Broadcast a version+interval message. */
    void sendMsg(TinyBlogMsg msg) {

        msg.set_sourceMoteID(3);
        msg.set_destMoteID(MOTEID);
        msg.set_seqno(seqno++);
        try {
            mote.send(MOTEID, msg);
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
