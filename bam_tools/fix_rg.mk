include modules/Makefile.inc
include modules/config/gatk.inc
include modules/config/align.inc

LOGDIR ?= log/fix_rg.$(NOW)

BAMS = $(foreach sample,$(SAMPLES),bam/$(sample).bam)
fixed_bams : $(BAMS) $(addsuffix .bai,$(BAMS))

bam/%.bam : unprocessed_bam/%.rg.bam
	$(INIT) ln -f $(<) $(@)


include modules/bam_tools/process_bam.mk
