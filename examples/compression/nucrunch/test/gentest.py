from __future__ import print_function, division
import numpy as np
from crc8 import crc8

def saveAsPrg(fn,address,data):
	fo=open(fn,"wb")
	header=np.array((address&255,address/256),np.uint8).tostring()
	fo.write(header)
	fo.write(data)
	fo.close()

def debmp(img):
    print("img.shape=",img.shape)
    tiles=np.reshape(np.transpose(np.reshape(img,(25,8,40,8)),(0,2,1,3)),(1000,64))
    bmp=np.zeros((1000,8),np.uint8)
    vm=np.zeros((1000,),np.uint8)
    for i in range(1000):
        ti=tiles[i]
        palette=(list(set(list(ti)))+[0,0])[:2]
        palette.sort()
        if palette[1]&1==0:
            palette.reverse()
        bits=np.equal(ti,palette[1])*1
        bmp[i]=np.sum(np.reshape(bits,(8,8))*[128,64,32,16,8,4,2,1],axis=1)
        vm[i]=palette[1]*16+palette[0]
    return bmp,vm

j,i=np.indices((200,320))
ci=( ((j-183.0)**2+(i-30.5)**2)**.5/5.0+0.5).astype(np.int)%64
di=((np.arange(64)+62^1)+3)//4%16
im=di[ci]

sx=8
sy=80
w=304


bmp_c,vm_c=debmp(im)

im[sy  :,sx:][:8,:w]=(lambda i,j: (((np.pi*(j+4))**(i/12.0+1.3))%2).astype(np.int))(*np.indices((8,w)))+11
im[sy+8:,sx:][:8,:w]=(lambda i,j: (((np.pi*(j+4))**(i/11.0+1.4))%2).astype(np.int))(*np.indices((8,w)))+11




bmp,vm=debmp(im)
mem=np.zeros((1024*9),np.uint8)
mem[:8000]=bmp.flat
mem[8192:9192]=vm.flat

mem[-1]=crc8(mem[:-1])
print("crc8(mem[:-1])=",crc8(mem[:-1]))
print("crc8(mem)     =",crc8(mem))

saveAsPrg("bmp.prg",0x4000,mem.tostring())

saveAsPrg("bmp0.prg",0x4000,mem[:0x1000].tostring())
saveAsPrg("bmp1.prg",0x5000,mem[0x1000:].tostring())

mem[:8000]=bmp_c.flat
mem[8192:9192]=vm_c.flat
mem[-1]=crc8(mem[:-1])

c0=sx//8+40*(sy//8)
a0=c0*8
saveAsPrg("bmp_c.prg",0x4000+a0,mem[a0:].tostring())
