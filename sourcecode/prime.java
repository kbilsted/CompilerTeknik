class Prime
{
	static void main()
	{
		Prime ptr;
		ptr = new Prime();

		ptr.calc();
	}
	
	void calc()
	{
		int i;
		i = 0;
		
		while(i < 1)
		{
			loop(); // calc prime 3-32000
			i = i + 1;
		}
	}
	
	
	void loop()
	{
		int p;
		p = 3;
			
		while(p < 32000)
		{
			isPrime(p);
			p = p + 1;
		}
	}
	
			
	void isPrime(int p)
	{
		int i;
		i = 2;
		
		while(i < p)
		{
			if(p%i == 0)
			{
				return;
			}
			else
			{
				i = i + 1;
			}
		}

		if(i == p){}
		else{}
	}
}

		
	
	