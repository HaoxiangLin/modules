# This module is used for running defuse
# input: $(SAMPLES) 
# Options: PHRED64 = true/false
# Authors: Fong Chun Chan <fongchunchan@gmail.com>
#
include modules/Makefile.inc

DEFUSE_CONFIG_FILE = $(HOME)/share/usr/defuse-0.6.1/scripts/config.txt
#DEFUSE_CONFIG_FILE = /opt/common/defuse/defuse-0.6.1/scripts/config.txt
DEFUSE_FILTER = $(PERL) $(HOME)/share/scripts/filterDefuse.pl
DEFUSE_NORMAL_FILTER = $(PERL) $(HOME)/share/scripts/normalFilterDefuse.pl

RECURRENT_FUSIONS = $(RSCRIPT) $(HOME)/share/scripts/recurrentFusions.R
EXTRACT_COORDS = $(PERL) $(HOME)/share/scripts/extractCoordsFromDefuse.pl

LOGDIR = log/defuse.$(NOW)

# Runs defuse locally on the same node
LOCAL ?= FALSE

# Only applies if LOCAL is set to TRUE
NUM_CORES ?= 2

ifeq ($(LOCAL),true)
	DEFUSE_OPTS = -p $(NUM_CORES)
else
	DEFUSE_OPTS = -s sge -p 10
endif

.PHONY : all tables


#all : $(foreach sample,$(SAMPLES),defuse/$(sample).defuse_timestamp)
ALL = $(foreach sample,$(SAMPLES),defuse/tables/$(sample).defuse.txt)
ifdef NORMAL_DEFUSE_RESULTS
ALLTABLE = defuse/alltables/all.defuse.nft.oncofuse.merged.txt
ALLTABLE += defuse/alltables/all.defuse_ft.nft.oncofuse.merged.txt
ALL += defuse/recur_tables/recurFusions.defuse.nft.gene.txt
ALL += defuse/recur_tables/recurFusions.defuse_ft.nft.gene.txt
else
ALLTABLE = defuse/alltables/all.defuse.oncofuse.merged.txt
ALLTABLE += defuse/alltables/all.defuse_ft.oncofuse.merged.txt
ALL += defuse/recur_tables/recurFusions.defuse.gene.txt
ALL += defuse/recur_tables/recurFusions.defuse_ft.gene.txt
endif
all : $(ALLTABLE) $(ALL)


defuse/tables/%.defuse.txt defuse/tables/%.defuse_ft.txt : fastq/%.1.fastq.gz.md5 fastq/%.2.fastq.gz.md5
	$(INIT) $(CHECK_MD5) $(DEFUSE) -c $(DEFUSE_CONFIG_FILE) -1 $(word 1,$(^M)) -2 $(word 2,$(^M)) -o defuse/$* $(DEFUSE_OPTS) &> $(LOG) && \
	$(DEFUSE_FILTER) defuse/$*/results.filtered.tsv > defuse/tables/$*.defuse_ft.txt 2>> $(LOG) && \
	$(DEFUSE_FILTER) defuse/$*/results.tsv > defuse/tables/$*.defuse.txt 2>> $(LOG) \
	&& $(RMR) defuse/$*

defuse/alltables/all.%.txt : $(foreach sample,$(SAMPLES),defuse/tables/$(sample).%.txt)
	$(INIT) head -1 $< > $@ && for x in $^; do sed '1d' $$x >> $@; done

defuse/alltables/%.defuse_ft.nft.txt : defuse/alltables/%.defuse_ft.txt
	$(INIT) $(DEFUSE_NORMAL_FILTER) -w 1000 $(NORMAL_DEFUSE_RESULTS) $< > $@

defuse/alltables/%.defuse.nft.txt : defuse/alltables/%.defuse.txt
	$(INIT) $(DEFUSE_NORMAL_FILTER) -w 1000 $(NORMAL_DEFUSE_RESULTS) $< > $@

defuse/recur_tables/recurFusions.%.gene.txt : defuse/alltables/all.%.txt
	$(INIT) $(RECURRENT_FUSIONS) --geneCol1 upstream_gene --geneCol2 downstream_gene --sampleCol library_name --outPrefix $(@D)/recurFusions.$* $< 


defuse/alltables/%.coord.txt : defuse/alltables/%.txt
	$(INIT) $(EXTRACT_COORDS) -t $(ONCOFUSE_TISSUE_TYPE) $< > $@ 2> $(LOG)

include modules/fastq_tools/fastq.mk
include modules/sv_callers/oncofuse.mk
