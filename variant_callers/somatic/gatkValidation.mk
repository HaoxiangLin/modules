include modules/Makefile.inc
include modules/config/gatk.inc

LOGDIR ?= log/gatk_validation.$(NOW)

SOMATIC_BED ?= somatic.bed


.DELETE_ON_ERROR:
.SECONDARY: 
.PHONY : val_vcfs

val_vcfs : $(foreach pair,$(SAMPLE_PAIRS),vcf/$(pair).gatkval.vcf)

define gatkval-tumor-normal
vcf/$1_$2.gatkval.vcf : bam/$1.bam bam/$2.bam
	$$(call RUN,-n 4 -s 2.5G -m 3G,"$$(call GATK_MEM,8G) -T UnifiedGenotyper -glm BOTH -nt 4 -R $(REF_FASTA) --dbsnp $(DBSNP) -I $$< -I $$(<<) -L $(SOMATIC_BED) -o $$@ --output_mode EMIT_ALL_SITES")
endef
$(foreach pair,$(SAMPLE_PAIRS),$(eval $(call gatkval-tumor-normal,$(tumor.$(pair)),$(normal.$(pair)))))

