task DepthStat {

    String bam
    String bam_index
    String bam_stat
    String by
    String prefix
    String outdir
    Int thread
    String docker_image
    
    Int mem_min = thread * 2
    Int memory = if (mem_min > 8) then mem_min else 8


    command {
        mosdepth --by ${by} -t ${thread} -T 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100 ${outdir}/${prefix}/${prefix} ${bam}
    }
    
    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
        String depth_regions = "${outdir}/${prefix}/${prefix}.regions.bed.gz"
        String depth_thresholds = "${outdir}/${prefix}/${prefix}.thresholds.bed.gz"
        String depth_per_base = "${outdir}/${prefix}/${prefix}.per-base.bed.gz"
    }

}