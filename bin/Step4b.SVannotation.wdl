task SVannotation {
    
    String vcf
    String outprefix
    String outdir
    String annovarDB
    String publicsvDB
    String grandsvDB
    String docker_image
    
    
    command {
        
        Step4b.svannot.py --vcf ${vcf} --prefix ${outprefix}.sniffles.SVanno --db ${annovarDB} --annovar /usr/local/bin/table_annovar.pl --outdir ${outdir}/${outprefix}
        
        Step4b.svan.py --vcf ${vcf} --prefix ${outprefix}.sniffles.SVanno --outdir ${outdir}/${outprefix} --pub_dbdir ${publicsvDB} --local_dbdir ${grandsvDB}
        
        Step4b.table_maker.py ${outdir}/${outprefix}/${outprefix}.sniffles.SVanno.hg19.omim_chpo.xls ${outdir}/${outprefix}/${outprefix}.sniffles.SVanno.svan.tsv ${outdir}/${outprefix}/${outprefix}.sniffles.SVanno.hg19.final.svannot.xls
        
        Step4b.tab2excel.py --input_file ${outdir}/${outprefix}/${outprefix}.sniffles.SVanno.hg19.final.svannot.xls --output_file ${outdir}/${outprefix}/${outprefix}.sniffles.SVanno.hg19.final.svannot.xlsx
        
    }
    
    
    runtime {
        docker: docker_image
        cpu: 2
        memory: "4GB"
    }
    
    
    output {
        
        String annotated_vcf = "${outdir}/${outprefix}/${outprefix}.sniffles.hg19.final.svannot.xlsx"
        
    }
    
}