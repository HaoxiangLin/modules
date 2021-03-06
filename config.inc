ifndef CONFIG_INC

REF ?= b37
SEQ_PLATFORM ?= illumina
SAMPLE_SET_FILE ?= sample_sets.txt
SAMPLE_FILE ?= samples.txt
SAMPLE_SPLIT_FILE ?= samples.split.txt

# general interpreters
ANACONDA_PYTHON ?= python
PYTHON ?= python
PERL ?= perl
RSCRIPT ?= Rscript
R ?= R

# anaconda environments
ANACONDA_27_ENV ?= $(HOME)/share/usr/anaconda-envs/anaconda-2.7
JRFLAB_MODULES_ENV ?= $(HOME)/share/usr/anaconda-envs/jrflab-modules-0.1.4
SUFAM_ENV ?= $(HOME)/share/usr/anaconda-envs/sufam-dev
MUTSIG_REPORT_ENV ?= $(HOME)/share/usr/anaconda-envs/mutsig-report-0.0.1
VEP_ENV ?= $(HOME)/share/usr/anaconda-envs/variant-effect-predictor-86
DECONSTRUCTSIGS_ENV ?= $(HOME)/share/usr/anaconda-envs/deconstructsigs
PHANGORN_ENV ?= $(HOME)/share/usr/anaconda-envs/phangorn
FGBIO_ENV ?= $(HOME)/share/usr/anaconda-envs/fgbio-0.8.1
HATCHET_ENV ?= $(HOME)/share/usr/anaconda-envs/hatchet
MACHINA_ENV ?= $(HOME)/share/usr/anaconda-envs/machina
CNTMD_ENV ?= $(HOME)/share/usr/anaconda-envs/cnt-md
CNTILP_ENV ?= $(HOME)/share/usr/anaconda-envs/cnt-ilp
PHYLO_ENV ?= $(HOME)/share/usr/anaconda-envs/phylotools
MEDICC_ENV ?= $(HOME)/share/usr/anaconda-envs/medicc
ASCAT_ENV ?= $(HOME)/share/usr/anaconda-envs/ascat
SUPERHEAT_ENV ?= $(HOME)/share/usr/anaconda-envs/superheat-1.0.0
STAR_FUSION_ENV ?= $(HOME)/share/usr/anaconda-envs/star-fusion-1.0.0
FACETS_ENV ?= $(HOME)/share/usr/anaconda-envs/facets-0.5.6

# general paths
JARDIR ?= $(HOME)/share/usr/lib/java
JAVA6_BIN ?= $(HOME)/share/usr/jdk1.6.0_45/bin/java
JAVA7_BIN ?= $(HOME)/share/usr/jdk1.7.0_45/bin/java
JAVA8_BIN ?= $(HOME)/share/usr/jdk1.8.0_121/bin/java
JAVA_BIN ?=  $(JAVA8_BIN)
SCRIPTS_DIR ?= modules/dodo-cloning-kit
PICARD_DIR ?= $(JARDIR)/picard-1.92

# application specific paths
VEP_PATH = $(VEP_ENV)/bin
MEDICC_BIN = $(MEDICC_ENV)/opt/medicc
CNTILP_BIN = $(CNTILP_ENV)/opt/CNT-ILP/build
CNTMD_BIN = $(CNTMD_ENV)/opt/CNT-MD/build
MACHINA_BIN = $(MACHINA_ENV)/opt/machina/build
HATCHET_BIN = $(HATCHET_ENV)/opt/machina/build

# java applications
MUTECT_JAR ?= $(JARDIR)/muTect-1.1.7.jar
SNP_EFF_JAR ?= $(JARDIR)/snpEff-4.3.jar
SNP_SIFT_JAR ?= $(JARDIR)/SnpSift-4.3.jar
ONCOFUSE_JAR ?= $(HOME)/share/usr/oncofuse-1.0.9b2/Oncofuse.jar
VARSCAN_JAR ?= $(JARDIR)/VarScan.v2.3.9.jar
PICARD_JAR ?= $(JARDIR)/picard-tools-1.141/picard.jar
GATK_JAR ?= $(JARDIR)/GenomeAnalysisTK.jar
GATK_JAR2 ?= $(JARDIR)/GenomeAnalysisTK-3.7.jar
MARIANAS ?= $(HOME)/share/usr/marianas-1.8.1/Marianas-1.8.1.jar
WALTZ ?= $(HOME)/share/usr/marianas-1.8.1/Waltz-3.0.jar

# configurations
HATCHET_VAR ?= modules/config/hatchet.conf
MACHINA_VAR ?= modules/config/machina.conf
CNTMD_CONF ?= modules/config/cnt-md.conf
CNTILP_CONF ?= modules/config/cnt-ilp.conf
MEDICC_VAR ?= modules/config/medicc.conf
SNP_EFF_CONFIG ?= modules/config/snpEff.conf
SNVBOX_CONF ?= modules/db/snv_box-$(MYSQLDB_HOST).conf
FATHMM_CONF ?= modules/db/fathmm_config-$(MYSQLDB_HOST).ini

# application aliasses
BWA ?= bwa
SAMTOOLS ?= samtools
SAMTOOLS2 ?= samtools
BCFTOOLS2 ?= bcftools
BCFTOOLS ?= bcftools
CUFFLINKS ?= cufflinks
CUFFCMP ?= cuffcompare
TOPHAT ?= tophat

SPLIT_BED = python $(SCRIPTS_DIR)/runtime/split_bed.py
NORMAL_FILTER ?= $(PERL) $(SCRIPTS_DIR)/runtime/normalFilterVCF.pl
SOMATIC_FILTER_VCF ?= $(PERL) $(SCRIPTS_DIR)/runtime/somaticFilterVCF.pl
MERGE ?= $(SCRIPTS_DIR)/runtime/merge.R
VCF_TO_TABLE ?= $(SCRIPTS_DIR)/runtime/vcfToTable.R
INTRON_POSN_LOOKUP ?= $(SCRIPTS_DIR)/runtime/posnGeneLookup.pl
RBIND ?= $(SCRIPTS_DIR)/runtime/rbind.R
INDEL_FILTER_VCF = python $(SCRIPTS_DIR)/vcf_tools/indel_filter_vcf.py
SNP_FILTER_VCF = python $(SCRIPTS_DIR)/vcf_tools/snp_filter_vcf.py
MERGE_VCF = python $(SCRIPTS_DIR)/vcf_tools/merge_vcf.py
KNIT = $(RSCRIPT) $(SCRIPTS_DIR)/runtime/knit.R
PASS_FILTER_VCF = python $(SCRIPTS_DIR)/vcf_tools/pass_filter_vcf.py
STAR_FUSION_TO_USV = python $(SCRIPTS_DIR)/structural_variants/starfusion2usv.py
CLONEHD = $(HOME)/share/usr/bin/cloneHD
FILTERHD = $(HOME)/share/usr/bin/filterHD
PREFILTER = $(HOME)/share/usr/bin/pre-filter
TABLE_TO_CLONEHD = $(PERL) $(SCRIPTS_DIR)/clonality/table2clonehd.pl

ANNOVAR = $(PERL) $(HOME)/share/usr/annovar-2017-07-16/table_annovar.pl
VCF2MAF ?= $(PERL) $(HOME)/share/usr/bin/vcf2maf.pl
MAF2MAF ?= $(PERL) $(HOME)/share/usr/bin/maf2maf.pl
MAF2VCF ?= $(PERL) $(HOME)/share/usr/bin/maf2vcf.pl

UNZIP ?= /usr/bin/unzip
FASTQC ?= $(PERL) $(HOME)/share/usr/FastQC/fastqc
BOWTIE ?= $(PERL) $(HOME)/share/usr/bowtie2-2.2.4/bowtie2
VCFUTILS ?= $(HOME)/share/usr/bin/vcfutils.pl
BEDTOOLS ?= $(HOME)/share/usr/bin/bedtools
BGZIP ?= $(HOME)/share/usr/bin/bgzip
IGVTOOLS ?= $(HOME)/share/usr/IGVTools/igvtools
VCFTOOLS ?= $(HOME)/share/usr/bin/vcftools-0.1.10
VCF_SORT ?= $(PERL) $(HOME)/share/usr/bin/vcfsorter.pl
DEFUSE ?= $(PERL) $(HOME)/share/usr/defuse-0.6.1/scripts/defuse.pl
GET_INSERT_SIZE ?= $(HOME)/share/usr/bin/getInsertSize.py
VT ?= $(HOME)/share/usr/bin/vt
TABIX ?= $(HOME)/share/usr/bin/tabix
INTEGRATE ?= $(HOME)/share/usr/Integrate_0.2.0/bin/Integrate
HISAT ?= $(HOME)/share/usr/hisat2-2.0.2-beta/hisat2
TVC ?= $(HOME)/share/usr/bin/tvc
TMAP ?= $(HOME)/share/usr/bin/tmap

# resources
DB_NSFP ?= $(HOME)/share/reference/snpEff-4.1/dbNSFP3.0b1a.hg19.txt.gz
WALTZ_BED_FILE ?= $(HOME)/share/reference/target_panels/MSK-ACCESS-v1_0-probe-A.waltz.bed
NSFP_FIELDS ?= Uniprot_acc_Polyphen2 Uniprot_id_Polyphen2 Polyphen2_HVAR_score Polyphen2_HVAR_pred 1000Gp3_AF ESP6500_AA_AF ESP6500_EA_AF MutationAssessor_pred MutationAssessor_score MutationTaster_pred MutationTaster_score PROVEAN_pred ExAC_Adj_AF clinvar_rs clinvar_clnsig Interpro_domain
UMI_QC_BED_FILE_A ?= $(HOME)/share/reference/target_panels/MSK-ACCESS-v1_0-probe-A.sorted.bed
UMI_QC_BED_FILE_B ?= $(HOME)/share/reference/target_panels/MSK-ACCESS-v1_0-probe-B.sorted.bed

# mysql configurations
MYSQLDB_HOST = swan
EMBL_MYSQLDB_HOST = swan
EMBL_MYSQLDB_PORT = 38493
EMBL_MYSQLDB_USER = embl
EMBL_MYSQLDB_PW = embl
EMBL_MYSQLDB_DB = homo_sapiens_core_75_37

endif
CONFIG_INC = true
