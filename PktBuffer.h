
#include "ForwardingPkts.h"

#define BUFFSIZE 32

typedef struct packet_info{
	uint8_t seqno;
	uint8_t srcid;
}PktInfo;

PktInfo buff[32];
uint8_t in = 0;
uint8_t out = 0;



void push(forwarder_t *pkt){
	buff[in].seqno = pkt->seqno;
	buff[in].srcid = pkt->srcid;
	in = (in + 1) % BUFFSIZE;
}

void pop(){
	out = (out - 1) % BUFFSIZE;
}

int check(forwarder_t *pkt){
	int i = 0;
	for (; i < BUFFSIZE; i++){
		if (buff[i].srcid == pkt->srcid && buff[i].seqno == pkt->seqno){
			return 1;
		}
	}
	return 0;
}