task MedakaVariant{
    
    String bam
    String reference
    Array[String] region
    String outdir
    String outprefix
    String medaka_model
    Int thread
    String docker_image
    
    Int mem_min = thread * 2
    Int memory = if (mem_min > 32) then mem_min else 32
    
    String chrom = region[0]
    String start = region[1]
    String end = region[2]


    command {
        
        #conda activate medaka
        medaka_variant -i ${bam} -f ${reference} -r ${chrom}:${start}-${end} -o ${outdir}/${outprefix}/${outprefix}_medaka_${chrom}_${start}_${end} -s ${default="r941_prom_high" medaka_model} -m ${default="r941_prom_high" medaka_model} -T 0.04 -t ${thread} -b 150
        #conda deactivate
        
    }
    
    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
        
        String vcf_String = "${outdir}/${outprefix}/${outprefix}_medaka_${chrom}_${start}_${end}/round_1_phased.vcf"
        
    }
    
}
