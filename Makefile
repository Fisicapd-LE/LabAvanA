#include gmsl

# commands /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SHELL=/bin/bash -O extglob -c

glob = $(shell script/glob "$(1)")

define echolog
	@tput setaf 6
	@echo $1
	@tput sgr0
endef

define clean
	@rm $1 2>/dev/null || true
endef

extract_raw = $(foreach raw,$(call glob,raw/$(1)/*.!(txt)),$(call strip_name,$(raw)))

extract_composed = $(foreach raw,$(call glob,raw/$(1)/*@*),$(firstword $(subst @, ,$(call strip_name,$(raw)))))

uniq = $(if $1,$(firstword $(1)) $(call uniq,$(filter-out $(firstword $(1)),$(1))))

img_candidate = $(firstword $(foreach ext,$(MEDIA_EXT),$(call glob,raw/$(1)/$(2)*(_nofloat).$(ext))))

compose_dependency = $(call glob,raw/$(1)/$(2)@*.!(txt))

strip_name = $(notdir $(basename $(1)))

# definitions //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FILE_REL_TEX = $(wildcard ./latex/*.tex)
BASENAME_REL = $(shell basename -a $(FILE_REL_TEX))

TARGETS = lualatex pdflatex general
MEDIA_EXT = tex pdf png jpg

PACK_CAT = $(foreach target,$(TARGETS),latex/preamble/packages/packages_$(target).tex)
MACRO_CAT = $(foreach target,$(TARGETS),latex/preamble/macros/macros_$(target).tex)

GRAPHS_BASE = $(call extract_raw,graph)
GRAPHS = $(call uniq,$(foreach graph,$(GRAPHS_BASE),latex/graph/$(graph).tex))
GRAPHS_COMPOSED_BASE = $(call uniq,$(call extract_composed,graph))
GRAPHS_COMPOSED = $(foreach graph,$(GRAPHS_COMPOSED_BASE),latex/graph/$(graph).tex)

IMGS_BASE = $(call extract_raw,img)
IMGS = $(call uniq,$(foreach img,$(IMGS_BASE),latex/img/$(img).tex))
IMGS_COMPOSED_BASE = $(call uniq,$(call extract_composed,img))
IMGS_COMPOSED = $(foreach img,$(IMGS_COMPOSED_BASE),latex/img/$(img).tex)

TABLES_BASE = $(call extract_raw,table)
TABLES = $(call uniq,$(foreach table,$(TABLES_BASE),latex/table/$(table).tex))



.PHONY: clean cleanlog  preamble packlog macrolog  media graph img latex chapters appendix code clean_preamble clean_graphs clean_imgs clean_tables
#macroaux graphs img chapters appendix

# main /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

all: preamble media latex
	cp latex/Relazione.pdf .
	cp latex/Relazione.pdf backup

latex: chapters appendix code
	$(call echolog,"Building thesis...")
	cd ./latex;	pwd; latexmk -pdf $(BASENAME_REL)
	
./latex/section/chapters.tex: ./latex/section/chapters
	
chapters: ./latex/section/chapters.tex
	script/compose/chapters.sh "chapters"
		
./latex/section/appendix.tex: ./latex/section/chapters
	
appendix: ./latex/section/appendix.tex
	script/compose/chapters.sh "appendix"
		
./latex/section/code.tex: ./latex/section/chapters
	
code: ./latex/section/code.tex
	script/compose/chapters.sh "code"
	
publish:
	if [ -f info/publish ]; \
	then \
		cp latex/Relazione.pdf $(shell cat info/publish); \
	fi;
	

# clean ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
clean: | cleanlog clean_preamble clean_graphs clean_imgs clean_tables
	-cd ./latex; pwd; latexmk -C -pdf $(BASENAME_REL)
	rm Relazione.pdf

cleanlog:
	$(call echolog,"Cleaning...")


# preamble /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
preamble: latex/preamble/packages.tex latex/preamble/macros.tex


latex/preamble/packages.tex: | packlog $(PACK_CAT)

packlog:
	$(call echolog, "Checking for new packages...")

$(PACK_CAT): latex/preamble/packages/packages_%.tex: latex/preamble/packages/% script/compose/packages.sh
	$(call echolog,"Found new $* packages")
	script/compose/packages.sh $*

latex/preamble/macros.tex: | macrolog $(MACRO_CAT)

macrolog:
	$(call echolog,"Checking for new macros...")
	
$(MACRO_CAT): latex/preamble/macros/macros_%.tex: latex/preamble/macros/% script/compose/macros.sh
	$(call echolog,"Found new $* macros")
	script/compose/macros.sh $*

clean_preamble:
	$(call echolog,"Cleaning preamble...")
	$(call clean,$(PACK_CAT))
	$(call clean,$(MACRO_CAT))


.SECONDEXPANSION:
# media ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

media: graph img table


graph: | graphlog $(GRAPHS) $(GRAPHS_COMPOSED)

graphlog:
	$(call echolog,"Formatting graphs...")
	
$(GRAPHS): latex/graph/%.tex: $$(call img_candidate,graph,%) $$(wildcard raw/graphs/%.txt) script/to_latex/cleanup.py script/to_latex/img.py
	$(call echolog,"Formatting $*...")
	script/to_latex/img.py $* graph $(suffix $(call img_candidate,graph,$*))
	
$(GRAPHS_COMPOSED): latex/graph/%.tex: $$(call compose_dependency,graph,%) $$(wildcard raw/graph/%.txt) script/to_latex/compose_img.py
	$(call echolog,"Composing $*...")
#	echo $(call compose_dependency,graph,$*)
	script/to_latex/compose_img.py $* graph $(foreach name,$(call compose_dependency,graph,$*),$(call strip_name,$(name)))
	
clean_graphs:
	$(call echolog,"Cleaning graphs...")
	$(call clean,$(GRAPHS))
	$(call clean,$(GRAPHS_COMPOSED))
	
	
img: | imglog $(IMGS) $(IMGS_COMPOSED)

imglog:
	$(call echolog,"Formatting imgs...")
	
$(IMGS): latex/img/%.tex: $$(call img_candidate,img,%) $$(wildcard raw/imgs/%.txt) script/to_latex/cleanup.py script/to_latex/img.py
	$(call echolog,"Formatting $*...")
	script/to_latex/img.py $* img $(suffix $(call img_candidate,img,$*))
	
$(IMGS_COMPOSED): latex/img/%.tex: $$(call compose_dependency,img,%) $$(wildcard raw/img/%.txt) script/to_latex/compose_img.py
	$(call echolog,"Composing $*...")
	script/to_latex/compose_img.py $* img $(foreach name,$(call compose_dependency,img,$*),$(call strip_name,$(name)))
	
clean_imgs:
	$(call echolog,"Cleaning imgs...")
	$(call clean,$(IMGS))
	$(call clean,$(IMGS_COMPOSED))
	

table: | tablelog $(TABLES)

tablelog:
	$(call echolog,"Formatting tables...")
	
$(TABLES): latex/table/%.tex: raw/table/%.dat $$(wildcard raw/table/%.txt) script/to_latex/cleanup.py script/to_latex/table.py aux/table
	$(call echolog,"Formatting $*...")
	script/to_latex/table.py $*
	
clean_tables:
	$(call echolog,"Cleaning tables...")
	$(call clean,$(TABLES))
	
