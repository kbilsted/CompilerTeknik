class A
{
	
	void main()
	{
		
		String s1;
		String s2;
		String s3;
		
		s1 = "hello";
		s2 = " assembly world";

		s3 = s1.concat(s2);
		s3.print();

		int len;
		len = s1.length();
		System.out.print(len);

		
		char c;
		c = s1.charAt(1);
		
		// note for at få det rigtige tegn har jeg 
		// udkommenteret add ax, 48  i asm koden! !
		System.out.print(c); 
	}
}


