main()
{
	calc();
}
	

void calc(void)
{
	int i;
	i = 0;
		
	while(i < 1)
	{
		loop(); // calc prime 3-32000

		i = i + 1;
	}
}
	
	
void loop(void)
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

		// we've got ourselves a prime!
		if(i == p)
		{}
		else{}
	}
}

		
	
	