#ifndef PKT_BUFFER_H
#define PKT_BUFFER_H
#include "TinyBlogMsg.h"

#define BUFFSIZE 32

typedef struct pkt_info{
	nx_uint8_t seqno;
	nx_uint16_t srcid;
}PktInfo;

#endif /* PKT_BUFFER_H */