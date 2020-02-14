str = "";
repeat (8)
{
    n = irandom_range(0, 15);
    if (n > 9)
    {
        str += chr(55 + n);
    }
    else
    {
        str += string(n);
    }
}
return str;

