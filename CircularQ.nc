
interface CircularQ{
	command void push(int val);
	command int pop ();
	command bool check(int val);
	command void createIterator();
	command int iterate();
}