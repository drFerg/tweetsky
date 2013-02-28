#include "PktBuffer.h"

module PktBufferC {
	provides interface PktBuffer;
}


implementation{
	PktInfo buff[32];
	uint8_t in = 0;
	uint8_t out = 0;



	command void PktBuffer.push(tinyblog_t *pkt){
		buff[in].seqno = pkt->seqno;
		buff[in].srcid = pkt->sourceMoteID;
		in = (in + 1) % BUFFSIZE;
	}

	command void PktBuffer.pop(){
		out = (out + 1) % BUFFSIZE;
	}

	command int PktBuffer.check(tinyblog_t *pkt){
		int i = 0;
		for (; i < BUFFSIZE; i++){
			if (buff[i].srcid == pkt->sourceMoteID && buff[i].seqno == pkt->seqno){
				return 1;
			}
		}
		return 0;
	}
}