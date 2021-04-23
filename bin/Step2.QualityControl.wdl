import "./bin/Step2a.QC_DepthStat.wdl" as DepthStat
import "./bin/Step2b.QC_OutStat.wdl" as OutStat
import "./bin/Step2c.QC_RmFile.wdl" as QCRmFile

workflow Capture_Evaluation {
    
    String capture
    String exon_bed
    String bam
    String bam_index
    String bam_stat
    String prefix
    String outdir
    Boolean rmfile
    Int thread
    String docker_image

    Array[String] Bed = if (capture!="") then ["1000", exon_bed, capture] else ["1000", exon_bed]
    
    
    scatter (bed in Bed) {
        call DepthStat.DepthStat as DepthStat {
            input:
            bam = bam,
            bam_index = bam_index,
            bam_stat = bam_stat,
            prefix = prefix,
            outdir = outdir,
            by = bed,
            thread = thread,
            docker_image = docker_image
        }
    }
    
    if (capture!="") {
        call OutStat.OutStat as OutStat {
            input:
            BamStat = bam_stat,
            bam = bam,
            bam_index = bam_index,
            bam_stat = bam_stat,
            capture_bed = capture,
            depth_regions_array = DepthStat.depth_regions,
            depth_thresholds_array = DepthStat.depth_thresholds,
            depth_per_base_array = DepthStat.depth_per_base,
            outdir = outdir,
            prefix = prefix,
            docker_image = docker_image
        }
    }
    
    
    #if (rmfile) {
    #    call QCRmFile.QCRmFile as RmFile {
    #        input:
    #            outdir = outdir,
    #            prefix = prefix,
    #            depth_regions_array = DepthStat.depth_regions,
    #            depth_thresholds_array = DepthStat.depth_thresholds,
    #            depth_per_base_array = DepthStat.depth_per_base,
    #            docker_image = docker_image
    #    }
    #}
    
}
