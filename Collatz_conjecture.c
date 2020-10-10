#include<stdio.h> 

int count=0;
int f(int n) 
{
    if(n==1)
    {
        return count;
    }
    else if(n%2==0) 
    { 
        f(n/2);
        count++; 	
    }
    else 
    { 
        f(3*n+1);
        count++; 	 
    }
} 
int main(void) 
{ 
    int n=10; 
    int step=f(n); 
    printf("Collatz conjecture (%d) = %d",n,step);
}
