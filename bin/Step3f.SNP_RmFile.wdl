task SNPRmFile{

    String outdir
    String outprefix
    String docker_image

    command {
        
        rm ${outdir}/${outprefix}/${outprefix}.capture.region
        rm ${outdir}/${outprefix}/${outprefix}.clair.*vcf
        rm -rf ${outdir}/${outprefix}/${outprefix}_medaka_*/
        rm ${outdir}/${outprefix}/${outprefix}.clair_merge.annovar.avinput ${outdir}/${outprefix}/${outprefix}.medaka_merge.annovar.avinput
        
    }    
    
    runtime {
        docker: docker_image
        cpu: 1
        memory: "4GB"
    }

}
