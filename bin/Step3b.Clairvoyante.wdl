task Clairvoyante {
    
    String bam
    Array[String] region
    String model
    String frequency
    String reference
    String outdir
    String outprefix
    String depth
    Int thread
    String docker_image

    String chrom = region[0]
    String start = region[1]
    String end = region[2]
    
    Int mem_min = thread * 2
    Int memory = if (mem_min > 32) then mem_min else 32

    command {
        
        #conda activate clairvoyante
        clairvoyante.py callVarBam --chkpnt_fn $clair_model_path/${model} --bam_fn ${bam} --ref_fn ${reference} --sampleName ${outprefix} --call_fn ${outdir}/${outprefix}/${outprefix}.clair.${chrom}_${start}_${end}.vcf --ctgName ${chrom} --ctgStart ${start} --ctgEnd ${end} --thread ${thread} --threshold ${frequency} --minCoverage ${depth}
        #conda deactivate
        
    }
    
    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
        String clair_vcf = "${outdir}/${outprefix}/${outprefix}.clair.${chrom}_${start}_${end}.vcf"
    }
    
}