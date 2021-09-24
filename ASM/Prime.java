class Prime
{
    static void main()
    {
        Prime ptr;
        ptr = new Prime();

        ptr.loop();
    }
    
    
    void loop()
    {
        int p; p = 3;
            
        while(p < 32000)
        {
            isPrime(p); p = p + 1;
        }
    }
    
            
    void isPrime(int p)
    {
        int i; i = 2;
        
        while(i < p)
        {
            if(p%i == 0){return; }
            else{i = i + 1; }
        }

        if(i == p){}
        else{}
    }
}