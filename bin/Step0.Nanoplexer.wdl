task Nanoplexer {

    # arguments
    # inputs
    String fqdir
    String barcode
    String outdir
    # run config
    Int thread
    String docker_image

    Int mem_min = thread * 2
    Int memory = if (mem_min > 16) then mem_min else 16
    
    command {
        
        cat ${fqdir}/*.fastq | nanoplexer -t ${thread} -b ${barcode} -p ${outdir} -
    
    }

    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }
    
    output {
        Array[String] fastq_list = glob("${outdir}/*.fastq")
        #Globs can be used to define outputs which contain many Strings. The glob function generates an array of String outputs
    }

}

