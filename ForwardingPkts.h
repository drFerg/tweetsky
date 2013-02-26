/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

// @author David Gay

#ifndef FORWARDINGPKTS_H
#define FORWARDINGPKTS_H

enum {
  /* Number of readings per message. If you increase this, you may have to
     increase the message_t size. */
  NREADINGS = 10,

  /* Default sampling period. */
  DEFAULT_INTERVAL = 5000,

  AM_FORWARDINGPKTS = 0x83
};

typedef nx_struct forwarder {
  nx_uint8_t seqno; /* Sequence number to create packet identifier */
  nx_uint8_t dstid; /* dest ID */
  nx_uint8_t srcid; /* src ID */
  nx_uint8_t ttl;
  nx_uint8_t val;
} forwarder_t;

#endif
