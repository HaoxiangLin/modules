include modules/Makefile.inc

LOGDIR = log/recurrent_mutations.$(NOW)

EXCEL_NONSYNONYMOUS_MUTECT_SNPS ?= summary/tsv/snv_nonsynonymous_summary.tsv
EXCEL_NONSYNONYMOUS_MUTECT_INDELS ?= summary/tsv/indel_nonsynonymous_summary.tsv

# sufam mpileup parameters
SUFAM_MPILEUP_PARAMS=--mpileup-parameters '-A --ignore-RG --min-MQ 1 --max-depth 500000 --max-idepth 500000'

# sufam plot parameters
SUFAM_PLOT_MIN_NR_SAMPLES_WITH_MUTATION?=1
SUFAM_PLOT_SAMPLE_ORDER?=$(SAMPLES)


recurrent_mutations: recurrent_mutations/recurrent_mutations.tsv recurrent_mutations/sufam/all_mutations.vcf recurrent_mutations/sufam/all_sufam.txt recurrent_mutations/sufam/sufam.ipynb recurrent_mutations/sufam/sufam.html

recurrent_mutations_sufam: recurrent_mutations/sufam/all_mutations.vcf recurrent_mutations/sufam/all_sufam.txt recurrent_mutations/sufam/sufam.ipynb recurrent_mutations/sufam/sufam.html

recurrent_mutations/recurrent_mutations.tsv: $(EXCEL_NONSYNONYMOUS_MUTECT_SNPS) $(EXCEL_NONSYNONYMOUS_MUTECT_INDELS)
	$(INIT) unset PYTHONPATH && \
	source $(ANACONDA_27_ENV)/bin/activate $(ANACONDA_27_ENV) && \
	python $(SCRIPTS_DIR)/runtime/recurrent_mutations_plot.py --summary_config summary_config.yaml $^ $(@D)

recurrent_mutations/sufam/all_mutations.vcf: $(EXCEL_NONSYNONYMOUS_MUTECT_SNPS) $(EXCEL_NONSYNONYMOUS_MUTECT_INDELS)
	$(INIT) unset PYTHONPATH && \
	source $(ANACONDA_27_ENV)/bin/activate $(ANACONDA_27_ENV) && \
	(csvcut -tc CHROM,POS,REF,ALT,ANN[*].GENE,ANN[*].HGVS_P,ANN[*].IMPACT,ANN[*].EFFECT $< | head -1 | sed 's/CHROM/#CHROM/'; \
	 csvcut -tc CHROM,POS,REF,ALT,ANN[*].GENE,ANN[*].HGVS_P,ANN[*].IMPACT,ANN[*].EFFECT $< | tail -n +2 | sort -u; \
	 csvcut -tc CHROM,POS,REF,ALT,ANN[*].GENE,ANN[*].HGVS_P,ANN[*].IMPACT,ANN[*].EFFECT $(<<) | tail -n +2 | sort -u) | csvformat -T > $@

recurrent_mutations/sufam/%_validated_sufam.txt: recurrent_mutations/sufam/all_mutations.vcf bam/%.bam
	$(INIT) unset PYTHONPATH && \
		source $(SUFAM_ENV)/bin/activate \
			   $(SUFAM_ENV) && \
		sufam $(SUFAM_MPILEUP_PARAMS) --sample_name $* $(REF_FASTA) $< $(<<) > $@

recurrent_mutations/sufam/all_sufam.txt: $(foreach sample,$(SAMPLES),recurrent_mutations/sufam/$(sample)_validated_sufam.txt)
	$(INIT) (head -1 $<; tail -qn +2 $^) > $@

recurrent_mutations/sufam/sufam.ipynb: recurrent_mutations/sufam/all_sufam.txt recurrent_mutations/sufam/all_mutations.vcf
	$(INIT) unset PYTHONPATH && \
		source $(ANACONDA_27_ENV)/bin/activate $(ANACONDA_27_ENV) && \
		cd $(@D) && cat ../../modules/scripts/recurrent_mutations_sufam.ipynb | \
		sed "s:ALL_SUFAM:`basename $<`:" | sed "s:SUFAM_ANNOTATIONS_VCF:`basename $(<<)`:" | sed 's:MIN_NR_SAMPLES_WITH_MUTATION:$(SUFAM_PLOT_MIN_NR_SAMPLES_WITH_MUTATION):' | \
		sed 's:SAMPLE_ORDER:$(SUFAM_PLOT_SAMPLE_ORDER):' | \
		runipy --no-chdir - `basename $@`

recurrent_mutations/sufam/sufam.html: recurrent_mutations/sufam/sufam.ipynb
	$(INIT) unset PYTHONPATH && \
		source $(ANACONDA_27_ENV)/bin/activate $(ANACONDA_27_ENV) && \
		ipython nbconvert $< --to html --stdout > $@

.PHONY: recurrent_mutations
