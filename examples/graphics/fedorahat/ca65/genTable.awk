
BEGIN {
    # Generate table
    for(i=0;i<257;i++) {
        n=i*.0061359231515425649188723503579677790706;
        sn[i]=int(sin(n)*8192+0.5);
        cs[i]=cos(n)*8192*.0061359231515425649188723503579677790706;
    }

    maxE = 1e10;
    isum = int(cs[0]+0.5);

    for(add=-0.5; add<1.0; add += 1/128) {
        for(isum=45; isum<65; isum++) {
            val = 0;
            sum = isum;
            serr = 0;
            for(i=0;i<257;i++) {
                err = val - sn[i];
                if( i == 256 )
                    err = err * 4;
                if( err < 0 )
                    err = -err;
                if( err > serr )
                    serr = err;
                #serr += err;
                oval = val;
                val = val + sum;
                if( sn[i] < val && cs[i]+add < sum )
                    sum--;
            }
            if( maxE > serr ) {
                printf "Total error is=%d add=%f: %.4f   (last=%d)\n", isum, add, serr, oval;
                maxE = serr;
                bestIS = isum;
                bestADD = add;
            }
        }
    }

    file="tst.dat"
    sum = bestIS;
    val = 0;
    bit = 0;
    printf "\n        isum = %d\ngenTab: .byte ", bestIS;
    for(i=0;i<257;i++) {
        printf "%f\t%f\n", i*.0061359231515425649188723503579677790706, val/8192 > file
        val = val + sum;
        if( sn[i] < val && cs[i]+bestADD < sum ) {
            bit = bit + 1;
            sum--;
        }
        if( i % 8 == 7 ) {
            if( i == 127 )
                printf "$%02x\n        .byte ", bit
            else if( i == 255 )
                printf "$%02x", bit
            else
                printf "$%02x,", bit
            bit = 0;
        }
        else {
            bit = bit * 2;
        }
    }
    printf "\n; SUM=%d\n", sum;

}
