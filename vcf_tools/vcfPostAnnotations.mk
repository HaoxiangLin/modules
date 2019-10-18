include modules/config/titan.inc

SUMMARY_NO_REMOTE ?= false
PROVEAN_SCRIPT = $(HOME)/share/usr/bin/provean.sh
CLASSIFY_SNV_PATHOGENICITY = python $(SCRIPTS_DIR)/runtime/classify_snv_pathogenicity_vcf.py
CLASSIFY_SNV_PATHOGENICITY_OPTS = 
CLASSIFY_INDEL_PATHOGENICITY = python $(SCRIPTS_DIR)/runtime/classify_indel_pathogenicity_vcf.py
CLASSIFY_INDEL_PATHOGENICITY_OPTS = --provean_script $(PROVEAN_SCRIPT) \
							  $(if $(findstring true,$(USE_CLUSTER)),--cluster_mode $(CLUSTER_ENGINE), \
							  --cluster_mode none) \
							  --num_provean_threads 6 --mem_per_thread 3G $(if $(findstring true,$(SUMMARY_NO_REMOTE)),--no_remote)

MUTATION_TASTER = $(PYTHON) $(SCRIPTS_DIR)/vcf_tools/mutation_taster_vcf.py

PROVEAN = $(PYTHON) $(SCRIPTS_DIR)/runtime/provean_vcf.py

CHASM = $(RSCRIPT) $(SCRIPTS_DIR)/vcf_tools/chasmVcf.R
CHASM_DIR = $(HOME)/share/usr/CHASM-3.0/CHASM
SNVBOX_DIR = $(PWD)/modules/external/SNVBox
CHASM_CLASSIFIER ?= BRCA

FATHMM = $(RSCRIPT) $(SCRIPTS_DIR)/vcf_tools/fathmmVcf.R
FATHMM_DIR = $(PWD)/modules/external/fathmm
FATHMM_OPTS = --genome $(REF) --ensemblTxdb $(ENSEMBL_TXDB) --ref $(REF_FASTA) \
			  --fathmmDir $(FATHMM_DIR) --fathmmConfig $(FATHMM_CONF) \
			  --mysqlHost $(EMBL_MYSQLDB_HOST) --mysqlPort $(EMBL_MYSQLDB_PORT) --mysqlUser $(EMBL_MYSQLDB_USER) \
              $(if $(EMBL_MYSQLDB_PW),--mysqlPassword $(EMBL_MYSQLDB_PW)) --mysqlDb $(EMBL_MYSQLDB_DB)
              
PARSSNP_VCF = $(RSCRIPT) $(SCRIPTS_DIR)/vcf_tools/parsSNPVcf.R

ANNOTATE_FACETS_VCF = $(RSCRIPT) $(SCRIPTS_DIR)/copy_number/annotateFacets2Vcf.R
ANNOTATE_FACETS_CCF_VCF = $(RSCRIPT) $(SCRIPTS_DIR)/copy_number/annotateFacetsCCF2Vcf.R
CCF_RSCRIPT = $(SCRIPTS_DIR)/copy_number/ccf.R

vcf/%.snp_pathogen.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,-c -s 5G -m 8G,"$(CLASSIFY_SNV_PATHOGENICITY) $(CLASSIFY_SNV_PATHOGENICITY_OPTS) $< \
												> $@.tmp && $(call VERIFY_VCF,$@.tmp,$@)"))

vcf/%.indel_pathogen.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,--internet -s 2G -m 5G,"$(CLASSIFY_INDEL_PATHOGENICITY) \
														$(CLASSIFY_INDEL_PATHOGENICITY_OPTS) $< > $@.tmp && $(call VERIFY_VCF,$@.tmp,$@)"))

vcf/%.mut_taste.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,--internet -s 2G -m 5G,"$(MUTATION_TASTER) $< > $@.tmp && \
														$(call VERIFY_VCF,$@.tmp,$@)"))

vcf/%.provean.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,--internet -s 2G -m 5G,"$(PROVEAN) $< > $@.tmp && \
														$(call VERIFY_VCF,$@.tmp,$@)"))

vcf/%.chasm.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,-c -s 8G -m 17G,"cp $(SNVBOX_CONF) $(SNVBOX_DIR)/snv_box.conf && $(CHASM) --genome $(REF) --classifier $(subst $( ),$(,),$(CHASM_CLASSIFIER)) --chasmDir $(CHASM_DIR) --snvBoxDir $(SNVBOX_DIR) --outFile $@ $<"))

vcf/%.fathmm.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,-c -s 8G -m 10G,"$(FATHMM) $(FATHMM_OPTS) --outFile $@ $<"))

vcf/%.parssnp.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,-c -s 8G -m 10G,"$(PARSSNP_VCF) --parsnpRdata $(PARSSNP_RESOURCES) --outFile $@.tmp $< && $(call VERIFY_VCF,$@.tmp,$@)"))

define hrun-tumor-normal
vcf/$1_$2.%.hrun.vcf : vcf/$1_$2.%.vcf bam/$1.bam bam/$2.bam bam/$1.bai bam/$2.bai
	$$(call RUN,-c -n 4 -s 2G -m 3G,"$$(call GATK_MEM,8G) -T VariantAnnotator -nt 4 -R $$(REF_FASTA) -A HomopolymerRun --dbsnp $$(DBSNP) $$(foreach bam,$$(filter %.bam,$$^),-I $$(bam) ) -V $$< -L $$< -o $$@")
endef
$(foreach pair,$(SAMPLE_PAIRS),$(eval $(call hrun-tumor-normal,$(tumor.$(pair)),$(normal.$(pair)))))

define hrun-sample
vcf/$1.%.hrun.vcf : vcf/$1.%.vcf bam/$1.bam bam/$1.bai
	$$(call RUN,-c -n 4 -s 2G -m 3G,"$$(call GATK_MEM,8G) -T VariantAnnotator -nt 4 -R $$(REF_FASTA) -L $$< -A HomopolymerRun --dbsnp $$(DBSNP) $$(foreach bam,$$(filter %.bam,$$^),-I $$(bam) ) -V $$< -o $$@")
endef
$(foreach sample,$(SAMPLES),$(eval $(call hrun-sample,$(sample))))

vcf/%.nsfp.vcf : vcf/%.vcf
	$(call CHECK_VCF,$(call RUN,-c -s 16G -m 20G,"$(call SNP_SIFT_MEM,12G) dbnsfp $(SNP_SIFT_OPTS) -f $(subst $( ),$(,),$(NSFP_FIELDS)) -db $(DB_NSFP) $< | sed '/^##INFO=<ID=dbNSFP/ s/Character/String/; /^##INFO=<ID=dbNSFP_clinvar_rs/ s/Integer/String/;' > $@.tmp && $(call VERIFY_VCF,$@.tmp,$@)"))

define annotate-facets-pair
vcf/$1.%.facets.vcf : vcf/$1.%.vcf facets/cncf/$1.cncf.txt
	$$(call CHECK_VCF,$$(call RUN,-c -s 4G -m 6G,"$$(ANNOTATE_FACETS_VCF) --facetsFile $$(<<) --outFile $$@.tmp $$< && $$(call VERIFY_VCF,$$@.tmp,$$@)"))
endef
$(foreach pair,$(SAMPLE_PAIRS),$(eval $(call annotate-facets-pair,$(pair))))

define annotate-facets-pair
vcf/$1.%.facets_ccf.vcf : vcf/$1.%.vcf facets/cncf/$1.Rdata
	$$(call CHECK_VCF,$$(call RUN,-c -s 4G -m 6G,"$$(ANNOTATE_FACETS_CCF_VCF) --tumor $$(tumor.$1) --ccfRscript $$(CCF_RSCRIPT) --facetsRdata $$(<<) --outFile $$@.tmp $$< && $$(call VERIFY_VCF,$$@.tmp,$$@)"))
endef
$(foreach pair,$(SAMPLE_PAIRS),$(eval $(call annotate-facets-pair,$(pair))))

define titan-pair
vcf/$1.%.titan.vcf : vcf/$1.%.vcf titan/optclust_results_w$(TITAN_WINDOW_SIZE)_p$(DEFAULT_PLOIDY_PRIOR)/$1.titan_seg.txt
	$$(call RUN,-v 4G -s 6G -m "$$(ANNOTATE_TITAN_LOH_VCF) --titanSeg $$(<<) --outFile $$@.tmp $$< && $$(call VERIFY_VCF,$$@.tmp,$$@)")
endef
$(foreach pair,$(SAMPLE_PAIRS),$(eval $(call titan-pair,$(pair))))
