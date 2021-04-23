task AnnotateVcf {
    
    String vcf
    String outprefix
    String outdir
    String software
    String annovarDB
    String docker_image
    Int thread
    
    Int mem_min = thread * 2
    Int memory = if (mem_min > 16) then mem_min else 16

    
    command {
        
        table_annovar.pl ${vcf} ${annovarDB} --thread ${thread} -buildver hg19 -out ${outdir}/${outprefix}/${outprefix}.${software}_merge.annovar -otherinfo -nastring . -remove -protocol refGene,wgEncodeGencodeBasicV19,cpgIslandExt,cytoBand,wgRna,targetScanS,tfbsConsSites,genomicSuperDups,rmsk,wgEncodeBroadHmmGm12878HMM,wgEncodeBroadHmmH1hescHMM,wgEncodeBroadHmmHepg2HMM,wgEncodeBroadHmmHuvecHMM,wgEncodeBroadHmmK562HMM,gwasCatalog,phastConsElements46way,avsnp147,clinvar_20190211,1000g2015aug_eas,1000g2015aug_sas,1000g2015aug_eur,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_all,gnomad_exome,esp6500siv2_all,exac03,dbnsfp33a,gerp++gt2,cg69,intervar_20170202 --operation g,g,r,r,r,r,r,r,r,r,r,r,r,r,r,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f --argument '-hgvs  --splicing_threshold 20 ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,' -vcfinput 
        
    }
    
    
    runtime {
        docker: docker_image
        cpu: thread
        memory: memory + "GB"
    }    
}