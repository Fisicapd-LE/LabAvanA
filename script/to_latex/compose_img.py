#!/usr/bin/env python3

import sys

def composeImg(name, folder, *files):
	files = list(files)
	f = open("latex/" + folder + "/" + name + ".tex", "w")
	try:
		caption = open("raw/" + folder + "/" + name + ".txt", "r").read()
	except FileNotFoundError:
		caption = name.replace("_", " ")
		
	f.write("\\begin{figure}[H]\n")
	f.write("\\centering\n")
	
	for i in range(len(files)//3):
		for j in range(3):
			f.write("\inpugraph{" + files[2*i+j] + "}%\n")
			f.write("~\n")
		f.write("\\\\\n")
	
	for i in range(3*(len(files)//3),len(files[0])):
		f.write("\inputgraph{" + str(files[0][i]) + "}%\n")
		f.write("~\n")
	
	f.write("\\caption{" + caption + "}\n")
	f.write("\\label{gr:" + name + "}\n")
	f.write("\\end{figure}")
	
	return 0

composeImg(sys.argv[1], sys.argv[2], sys.argv[3:])
