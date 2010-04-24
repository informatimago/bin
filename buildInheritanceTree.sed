s/[	 ]*ILVDSPEXPORTED[	 ]*/ /g
s/[	 ]*ILVEDTEXPORTED[	 ]*/ /g
s/[	 ]*ILVGDTEXPORTED[	 ]*/ /g
s/[	 ]*ILVVAREXPORTED[	 ]*/ /g
s/[	 ]*ILVVWSEXPORTED[	 ]*/ /g
s/\/\/.*//
/class [^;]*$/{
N
N
N
N
N
N
N
N
s/\\*\n//g
s/#if.*#endif//
s/[	 ]*{.*//
s/class[	 ]*//
s/virtual//g
s/[	 ]*:[	 ]*public[	 ]*/	/g
s/[	 ]*,[	 ]*public[	 ]*/	/g
s/[	 ]*:[	 ]*/	/g
s/[	 ]*,[	 ]*/	/g
p
}


