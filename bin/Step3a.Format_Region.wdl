task FormatRegion {
    
    String capture
    String outdir
    String outprefix
    String docker_image

    command {
        
        Step3a.Format_Convert.py --bed ${capture} --type region --out ${outdir}/${outprefix}/${outprefix}.capture.region
 
    }
    
    runtime {
        docker: docker_image
        cpu: 1
        memory: "2GB"
    }
    
    output {
        
        String region_String = "${outdir}/${outprefix}/${outprefix}.capture.region"
        #Array[String] region = read_lines(region_String)
        Array[Array[String]] capture_tsv = read_tsv("${capture}")
    
    }
    
}