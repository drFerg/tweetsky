#include "TinyBlogMsg.h"
interface InterestTable {
	command void push(nx_uint16_t tweeterID, nx_uint16_t senderID);
	command void pop();
	command bool check(nx_uint16_t tweeterID);
	command nx_uint16_t getSender(nx_uint16_t tweeterID);
	command void expireInterests();
	command void refresh(nx_uint16_t tweeterID, nx_uint16_t senderID);

}
