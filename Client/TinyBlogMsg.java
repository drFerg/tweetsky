/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'TinyBlogMsg'
 * message type.
 */

public class TinyBlogMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 26;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 10;

    /** Create a new TinyBlogMsg of size 26. */
    public TinyBlogMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new TinyBlogMsg of the given data_length. */
    public TinyBlogMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg with the given data_length
     * and base offset.
     */
    public TinyBlogMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg using the given byte array
     * as backing store.
     */
    public TinyBlogMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public TinyBlogMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public TinyBlogMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg embedded in the given message
     * at the given base offset.
     */
    public TinyBlogMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TinyBlogMsg embedded in the given message
     * at the given base offset and length.
     */
    public TinyBlogMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <TinyBlogMsg> \n";
      try {
        s += "  [seqno=0x"+Long.toHexString(get_seqno())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [sourceMoteID=0x"+Long.toHexString(get_sourceMoteID())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [destMoteID=0x"+Long.toHexString(get_destMoteID())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [action=0x"+Long.toHexString(get_action())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [hopCount=0x"+Long.toHexString(get_hopCount())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [nchars=0x"+Long.toHexString(get_nchars())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [data=";
        for (int i = 0; i < 14; i++) {
          s += "0x"+Long.toHexString(getElement_data(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [mood=0x"+Long.toHexString(get_mood())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: seqno
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'seqno' is signed (false).
     */
    public static boolean isSigned_seqno() {
        return false;
    }

    /**
     * Return whether the field 'seqno' is an array (false).
     */
    public static boolean isArray_seqno() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'seqno'
     */
    public static int offset_seqno() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'seqno'
     */
    public static int offsetBits_seqno() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'seqno'
     */
    public short get_seqno() {
        return (short)getUIntBEElement(offsetBits_seqno(), 8);
    }

    /**
     * Set the value of the field 'seqno'
     */
    public void set_seqno(short value) {
        setUIntBEElement(offsetBits_seqno(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'seqno'
     */
    public static int size_seqno() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'seqno'
     */
    public static int sizeBits_seqno() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: sourceMoteID
    //   Field type: int, unsigned
    //   Offset (bits): 8
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'sourceMoteID' is signed (false).
     */
    public static boolean isSigned_sourceMoteID() {
        return false;
    }

    /**
     * Return whether the field 'sourceMoteID' is an array (false).
     */
    public static boolean isArray_sourceMoteID() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'sourceMoteID'
     */
    public static int offset_sourceMoteID() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'sourceMoteID'
     */
    public static int offsetBits_sourceMoteID() {
        return 8;
    }

    /**
     * Return the value (as a int) of the field 'sourceMoteID'
     */
    public int get_sourceMoteID() {
        return (int)getUIntBEElement(offsetBits_sourceMoteID(), 16);
    }

    /**
     * Set the value of the field 'sourceMoteID'
     */
    public void set_sourceMoteID(int value) {
        setUIntBEElement(offsetBits_sourceMoteID(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'sourceMoteID'
     */
    public static int size_sourceMoteID() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'sourceMoteID'
     */
    public static int sizeBits_sourceMoteID() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: destMoteID
    //   Field type: int, unsigned
    //   Offset (bits): 24
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'destMoteID' is signed (false).
     */
    public static boolean isSigned_destMoteID() {
        return false;
    }

    /**
     * Return whether the field 'destMoteID' is an array (false).
     */
    public static boolean isArray_destMoteID() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'destMoteID'
     */
    public static int offset_destMoteID() {
        return (24 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'destMoteID'
     */
    public static int offsetBits_destMoteID() {
        return 24;
    }

    /**
     * Return the value (as a int) of the field 'destMoteID'
     */
    public int get_destMoteID() {
        return (int)getUIntBEElement(offsetBits_destMoteID(), 16);
    }

    /**
     * Set the value of the field 'destMoteID'
     */
    public void set_destMoteID(int value) {
        setUIntBEElement(offsetBits_destMoteID(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'destMoteID'
     */
    public static int size_destMoteID() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'destMoteID'
     */
    public static int sizeBits_destMoteID() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: action
    //   Field type: short, unsigned
    //   Offset (bits): 40
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'action' is signed (false).
     */
    public static boolean isSigned_action() {
        return false;
    }

    /**
     * Return whether the field 'action' is an array (false).
     */
    public static boolean isArray_action() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'action'
     */
    public static int offset_action() {
        return (40 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'action'
     */
    public static int offsetBits_action() {
        return 40;
    }

    /**
     * Return the value (as a short) of the field 'action'
     */
    public short get_action() {
        return (short)getUIntBEElement(offsetBits_action(), 8);
    }

    /**
     * Set the value of the field 'action'
     */
    public void set_action(short value) {
        setUIntBEElement(offsetBits_action(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'action'
     */
    public static int size_action() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'action'
     */
    public static int sizeBits_action() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: hopCount
    //   Field type: short, unsigned
    //   Offset (bits): 48
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'hopCount' is signed (false).
     */
    public static boolean isSigned_hopCount() {
        return false;
    }

    /**
     * Return whether the field 'hopCount' is an array (false).
     */
    public static boolean isArray_hopCount() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'hopCount'
     */
    public static int offset_hopCount() {
        return (48 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'hopCount'
     */
    public static int offsetBits_hopCount() {
        return 48;
    }

    /**
     * Return the value (as a short) of the field 'hopCount'
     */
    public short get_hopCount() {
        return (short)getUIntBEElement(offsetBits_hopCount(), 8);
    }

    /**
     * Set the value of the field 'hopCount'
     */
    public void set_hopCount(short value) {
        setUIntBEElement(offsetBits_hopCount(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'hopCount'
     */
    public static int size_hopCount() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'hopCount'
     */
    public static int sizeBits_hopCount() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: nchars
    //   Field type: short, unsigned
    //   Offset (bits): 56
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'nchars' is signed (false).
     */
    public static boolean isSigned_nchars() {
        return false;
    }

    /**
     * Return whether the field 'nchars' is an array (false).
     */
    public static boolean isArray_nchars() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'nchars'
     */
    public static int offset_nchars() {
        return (56 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'nchars'
     */
    public static int offsetBits_nchars() {
        return 56;
    }

    /**
     * Return the value (as a short) of the field 'nchars'
     */
    public short get_nchars() {
        return (short)getUIntBEElement(offsetBits_nchars(), 8);
    }

    /**
     * Set the value of the field 'nchars'
     */
    public void set_nchars(short value) {
        setUIntBEElement(offsetBits_nchars(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'nchars'
     */
    public static int size_nchars() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'nchars'
     */
    public static int sizeBits_nchars() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: data
    //   Field type: short[], unsigned
    //   Offset (bits): 64
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'data' is signed (false).
     */
    public static boolean isSigned_data() {
        return false;
    }

    /**
     * Return whether the field 'data' is an array (true).
     */
    public static boolean isArray_data() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'data'
     */
    public static int offset_data(int index1) {
        int offset = 64;
        if (index1 < 0 || index1 >= 14) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'data'
     */
    public static int offsetBits_data(int index1) {
        int offset = 64;
        if (index1 < 0 || index1 >= 14) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'data' as a short[]
     */
    public short[] get_data() {
        short[] tmp = new short[14];
        for (int index0 = 0; index0 < numElements_data(0); index0++) {
            tmp[index0] = getElement_data(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'data' from the given short[]
     */
    public void set_data(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_data(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'data'
     */
    public short getElement_data(int index1) {
        return (short)getUIntBEElement(offsetBits_data(index1), 8);
    }

    /**
     * Set an element of the array 'data'
     */
    public void setElement_data(int index1, short value) {
        setUIntBEElement(offsetBits_data(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'data'
     */
    public static int totalSize_data() {
        return (112 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'data'
     */
    public static int totalSizeBits_data() {
        return 112;
    }

    /**
     * Return the size, in bytes, of each element of the array 'data'
     */
    public static int elementSize_data() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'data'
     */
    public static int elementSizeBits_data() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'data'
     */
    public static int numDimensions_data() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'data'
     */
    public static int numElements_data() {
        return 14;
    }

    /**
     * Return the number of elements in the array 'data'
     * for the given dimension.
     */
    public static int numElements_data(int dimension) {
      int array_dims[] = { 14,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'data' with a String
     */
    public void setString_data(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_data(i, (short)s.charAt(i));
         }
         setElement_data(i, (short)0); //null terminate
    }

    /**
     * Read the array 'data' as a String
     */
    public String getString_data() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,14)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_data(i) == (char)0) break;
             carr[i] = (char)getElement_data(i);
         }
         return new String(carr,0,i);
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: mood
    //   Field type: long, unsigned
    //   Offset (bits): 176
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'mood' is signed (false).
     */
    public static boolean isSigned_mood() {
        return false;
    }

    /**
     * Return whether the field 'mood' is an array (false).
     */
    public static boolean isArray_mood() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'mood'
     */
    public static int offset_mood() {
        return (176 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'mood'
     */
    public static int offsetBits_mood() {
        return 176;
    }

    /**
     * Return the value (as a long) of the field 'mood'
     */
    public long get_mood() {
        return (long)getUIntBEElement(offsetBits_mood(), 32);
    }

    /**
     * Set the value of the field 'mood'
     */
    public void set_mood(long value) {
        setUIntBEElement(offsetBits_mood(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'mood'
     */
    public static int size_mood() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'mood'
     */
    public static int sizeBits_mood() {
        return 32;
    }

}