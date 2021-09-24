class Qjava
{
   static void main(String[] args)
	{
		CompilerFacade cf;
		
		if(args.length == 1)
			cf = new CompilerFacade(args[0]+".java", args[0]+".asm");
		else	
			System.out.println("Qjava v1.0 by Kasper B. Graversen (c) 1999 - This is freeware\nUsage: Qjava <filename without extension>");
	}
}
