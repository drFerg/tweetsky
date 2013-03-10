#define CQSIZE 32

module CircularQC {
	provides interface CircularQ;
}
implementation{
	int queue[CQSIZE];
	uint8_t in = 0;
	uint8_t out = 0;
	uint8_t iterator = 0;
	command void CircularQ.push(int val){
		queue[in] = val;
		in = (in + 1) % CQSIZE;
	}

	command int CircularQ.pop(){
		int temp = queue[out];
		out = (out + 1) % CQSIZE;
		return temp;
	}

	command bool CircularQ.check(int val){
		int i;
		for (i = 0; i < CQSIZE; i++){
			if (queue[i] == val){
				return TRUE;
			}
		}
		return FALSE;
	}

	command void CircularQ.createIterator(){
		iterator = out;
	}
	command int CircularQ.iterate(){
		int temp;
		if (iterator != in){
			temp = queue[iterator];
			iterator = (iterator+1) % CQSIZE;
			return temp;
		}
		return -1;
	}

}