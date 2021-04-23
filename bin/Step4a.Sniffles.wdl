task Sniffles {
    
    String bam
    String bam_index
    String outdir
    String outprefix
    Int thread
    String docker_image
    
    Int mem_min = thread * 2
    Int memory = if (mem_min > 16) then mem_min else 16

    
    command {
        
        sniffles -t ${thread} -m ${bam} -v ${outdir}/${outprefix}/${outprefix}.sniffles.vcf --report_BND -n -1
        
    }
    
    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
    
        String sniffles_vcf = "${outdir}/${outprefix}/${outprefix}.sniffles.vcf"
    }
    
    
}