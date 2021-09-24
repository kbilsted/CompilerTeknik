class PrimeInline
{
	static void main(String[] args)
	{
	int i;
	i = 0;
		
	while(i < 1)
	{
		int p;
		p = 3;
			
		while(p < 32000)
		{

			int iii;
			iii = 2;
		
			while(iii < p)
			{ 
				if(p%iii == 0)
				{
					break;
				}
				else
				{
					iii = iii + 1;
				}
			}

			// we've got ourselves a prime!
			if(iii == p)
			{ }
			else{}


			p = p + 1;
		}

		i = i + 1;
	}

	}
}