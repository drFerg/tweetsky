#include "Interest.h"
#define INTEREST_TTL 5
module InterestTableC {
	provides interface InterestTable;
}


implementation{
	Interest interests[32];
	uint8_t in = 0;
	uint8_t out = 0;

	command void InterestTable.push(nx_uint16_t tweeterID, nx_uint16_t senderID){
		interests[in].tweeterID = tweeterID;
		interests[in].senderID = senderID;
		interests[in].ttl = INTEREST_TTL;
		in = (in + 1) % BUFFSIZE;
	}

	command void InterestTable.pop(){
		out = (out + 1) % BUFFSIZE;
	}

	command nx_uint16_t InterestTable.getSender(nx_uint16_t tweeterID){
		int i = 0;
		for (; i < BUFFSIZE; i++){
			if (interests[i].tweeterID == tweeterID && interests[i].ttl > 0)
				return interests[i].senderID;
		}
		return 0;
	}

	command bool InterestTable.check(nx_uint16_t tweeterID){
		int i = 0;
		for (; i < BUFFSIZE; i++){
			if (interests[i].tweeterID == tweeterID && interests[i].ttl > 0){
				return TRUE;
			}
		}
		return FALSE;
	}
	command void InterestTable.refresh(nx_uint16_t tweeterID, nx_uint16_t senderID){
		int i = 0;
		for (; i < BUFFSIZE; i++){
			if (interests[i].tweeterID == tweeterID && interests[i].senderID == senderID){
				interests[i].ttl += INTEREST_TTL;
			}
		}
	}

	command void InterestTable.expireInterests(){
		int i = 0;
		for (; i < BUFFSIZE; i++){
			if (interests[i].ttl > 0){
				interests[i].ttl--;
			}
		}
	}
}