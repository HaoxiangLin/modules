# run oncofuse
# hg19 only

ONCOFUSE_MEM = $(JAVA7) -Xmx$1 -jar $(HOME)/share/usr/oncofuse-v1.0.6/Oncofuse.jar
#ONCOFUSE_MEM = $(JAVA7) -Xmx$1 -jar $(HOME)/share/usr/lib/java/oncofuse-1.0.8.jar
ONCOFUSE_TISSUE_TYPE ?= EPI

%.oncofuse.txt : %.coord.txt
	$(call LSCRIPT_MEM,8G,12G,"$(call ONCOFUSE_MEM,7G) $< coord $(ONCOFUSE_TISSUE_TYPE) $@")

%.oncofuse.merged.txt : %.txt %.oncofuse.txt 
	$(INIT) head -1 $< | sed 's/^/RowID\t/' > $<.tmp && awk 'BEGIN {OFS = "\t" } NR > 1 { print NR-1, $$0 }' $< >> $<.tmp ;\
		cut -f 2- $(<<) > $(<<).tmp; \
		$(RSCRIPT) $(MERGE) -X --byColX 1 --byColY 1 -H $<.tmp $(<<).tmp > $@ && rm -f $<.tmp $(<<).tmp

