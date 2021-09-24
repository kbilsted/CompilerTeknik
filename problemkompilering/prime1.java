/* Dette program kan ikke assembleres, fordi while løkken er for stor */
class A
{
	void main()
	{
		String space;
		space = "*";
		String no;
		
		int p;
		int div;
		p = 1;
		
		while(p < 100)
		{
			div = 2;
			
			while(div != p && p%div != 0)
			{
				div = div + 1;
			}
		
			if(div == p)
			{
				no = toString(p);
				System.out.print(no);
				System.out.print(space);
			}
			else{}
			
			p = p + 1;
		}
	}
}


