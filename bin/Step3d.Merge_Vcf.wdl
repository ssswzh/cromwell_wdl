task MergeVcf {
    
    String outdir
    String outprefix
    String software
    Array[String] vcf_String_list
    String docker_image

    command {
        
        vcfcat ${sep=" " vcf_String_list} | vcfstreamsort > ${outdir}/${outprefix}/${outprefix}.${software}_merge.vcf
        
    }
    
    runtime {
        docker: docker_image
        cpu: 1
        memory: "4GB"
    }
    
    output {
        
        String merged_vcf = "${outdir}/${outprefix}/${outprefix}.${software}_merge.vcf"
        
    }
    
}