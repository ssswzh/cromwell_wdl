task OutStat {

    String BamStat
    String bam
    String bam_index
    String bam_stat
    String capture_bed
    Array[String] depth_regions_array
    Array[String] depth_thresholds_array
    Array[String] depth_per_base_array
    String prefix
    String outdir
    String docker_image
    
    
    command {
        Step2b.QC_FinalStat.py --prefix ${prefix}  --MapStat ${BamStat} --bam ${bam} --capture_bed ${capture_bed} --mosdepth_regions ${sep=',' depth_regions_array} --mosdepth_thresholds ${sep=',' depth_thresholds_array} --mosdepth_per_base ${sep=',' depth_per_base_array} --outdir ${outdir}/${prefix}
    }

    runtime {
        docker: docker_image
        cpu: 1
        memory: "4 GB"
    }

}

