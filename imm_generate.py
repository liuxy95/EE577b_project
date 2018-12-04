f = open("imem_p1.fill", "w")
f.write("00000000\n00000000\n")
brAddr_base = 8
memAddr_base = 32
for i in range(24):
	brAddr = brAddr_base + i*16
	memAddr = memAddr_base + i
	f.write("8020C003\n")
	f.write("8820"+'%.4x'%brAddr+"\n")
	f.write("8040C002\n")
	f.write("844000"+'%.2x'%memAddr+"\n")
f.write("00000000\n00000000\n")
f.close()
