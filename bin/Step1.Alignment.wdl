task Alignment {

    # arguments
    # inputs
    String fastq
    String reference
    String outdir
    String outprefix
    String platform
    # run config
    Int thread
    String docker_image

    Int mem_min = thread * 2
    Int memory = if (mem_min > 16) then mem_min else 16

    command {
        mkdir ${outdir}/${outprefix}
        minimap2 -L --MD -Y -a -t ${thread} --secondary=no -x map-${platform} ${reference} ${fastq} | samtools view -b - | samtools sort -m 4G -o ${outdir}/${outprefix}/${outprefix}.bam
        samtools index -@ ${thread} ${outdir}/${outprefix}/${outprefix}.bam
        samtools stats -@ ${thread} ${outdir}/${outprefix}/${outprefix}.bam > ${outdir}/${outprefix}/${outprefix}.bam.stat        
    }

    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
        String bam = "${outdir}/${outprefix}/${outprefix}.bam"
        String bam_index = "${outdir}/${outprefix}/${outprefix}.bam.bai"
        String bam_stat = "${outdir}/${outprefix}/${outprefix}.bam.stat"
    }

}

