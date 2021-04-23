task SVRmFile{

    String outdir
    String outprefix
    String docker_image

    command {
        
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.hg19_multianno.txt
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.hg19_multianno.xls
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.hg19.omim_chpo.xls
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.svan.tsv
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.sv.bed
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.vcf_tmp_genotype
        rm ${outdir}/${outprefix}/${outprefix}.sniffles.ainput
        
    }    
    
    runtime {
        docker: docker_image
        cpu: 1
        memory: "4GB"
    }

}
