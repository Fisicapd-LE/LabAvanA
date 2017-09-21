#!/usr/bin/env python3

import sys
import cleanup
import re
from string import Template

def compose_line(fields):
	line_sep = json.load(open("aux/table/line_model.tpl").readlines())
	
	write_line = line_sep['before']
	write_line += line_sep['middle'].join(write_fields)
	write_line += line_sep['after']
	
	return write_line
	
def compose_title(fields):
	title_sep = json.load(open("aux/table/title_model.tpl").readlines())
	
	write_title = title_sep['before']
	write_title += title_sep['middle'].join(write_fields)
	write_title += title_sep['after']
	
	return write_title
	
def compose_tbody(fields):
	tbody_sep = json.load(open("aux/table/tbody_model.tpl").readlines())
	
	write_tbody = tbody_sep['before']
	write_tbody += tbody_sep['middle'].join(write_fields)
	write_tbody += tbody_sep['after']
	
	return write_tbody

def tab_to_latex(name):
	cleanName = cleanup.cleanup(name)
	f = open("latex/table/" + cleanName + ".tex", "w")
	fin = open("raw/table/" + name + ".dat", "r")
	
	table_model = Template(open("aux/table/table_model.tpl").readlines())
	tbody_sep = json.load(open("aux/table/tbody_model.tpl").readlines())
	
	try:
		caption = open("raw/" + folder + "/" + cleanName + ".txt", "r").readlines()
	except FileNotFoundError:
		caption = cleanName
		
	title = fin.readline(0).lstrip()
	titlefields = re.split(r"\t+", title)
	cols = ""
	write_fields = []
	for field in titlefields:
		if field == "|":
			cols += "|"
		else:
			cols += "c"
			write_fields.insert(field)
			
	write_title = compose_title(write_fields)
	
	lines = []
	
	for line in fin:
		if line.startwith("#"):
			continue
		fields = re.split(r"\t+", line)
		lines.insert(compose_line(fields)
	tbody = compose_tbody(fields)
	
	table = table_model.substitute(titleline = write_title, tbody = tbody)
	
	
	f.write("\\begin{table}[" + ("H" if cleanup.flags["nofloat"] else "h") + "]\n")
	f.write(table)
	f.write("\\caption{" + caption + "}\n")
	f.write("\\label{tab:" + cleanName + "}\n")
	f.write("\\end{table}")
		
	f.close()
	return 0
	
tab_to_latex(sys.argv[1])
