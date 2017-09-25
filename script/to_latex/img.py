#!/usr/bin/env python3

import cleanup
import sys

def img_to_latex(name, folder, ext):
	cleanName = cleanup.cleanup(name)
	prefix = {"graph": "gr", "img": "img"}
	f = open("latex/" + folder + "/" + cleanName + ".tex", "w")
	try:
		caption = open("raw/" + folder + "/" + cleanName + ".txt", "r").readlines()
	except FileNotFoundError:
		caption = cleanName.replace("_", " ")
	
	if not cleanup.flags["sub"]:
		f.write("\\begin{figure}[" + ("H" if cleanup.flags["nofloat"] else "h") + "]\n")
	else:
		f.write("\\begin{subfigure}{0.40\\textwidth}\n")
	f.write("\\centering\n")
	if ext ==  ".tex":
		f.write("\\resizebox{0.9\\textwidth}{!}{\\input{../raw/" + folder + "/" + cleanName + ext + "}}\n")
	else:
		f.write("\\includegraphics[width=0.9\\textwidth]{../raw/" + folder + "/" + cleanName + ext + "}\n")
	f.write("\\caption{" + caption + "}\n")
	f.write("\\label{" + prefix[folder] + ":" + cleanName + "}\n")
	if not cleanup.flags["sub"]:
		f.write("\\end{figure}")
	else:
		f.write("\\end{subfigure}")
		
	f.close()
	return 0
	
img_to_latex(sys.argv[1], sys.argv[2], sys.argv[3])


