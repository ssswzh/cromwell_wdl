task QCRmFile{

    String outdir
    String prefix
    Array[String] depth_regions_array
    Array[String] depth_thresholds_array
    Array[String] depth_per_base_array
    String docker_image

    command {
        
        rm ${sep=' ' depth_regions_array} ${sep=' ' depth_thresholds_array} ${sep=' ' depth_per_base_array} ${outdir}/${prefix}/${prefix}.mosdepth.*
    }    
    
    runtime {
        docker: docker_image
        cpu: 1
        memory: "4 GB"
    }

}