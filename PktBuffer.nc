#include "TinyBlogMsg.h"
interface PktBuffer {
	command void push(tinyblog_t *pkt);
	command void pop();
	command int check(tinyblog_t *pkt);
}
