import "./bin/Step4a.Sniffles.wdl" as Step4aSniffles
import "./bin/Step4b.SVannotation.wdl" as Step4bSVannotation
import "./bin/Step4c.SV_RmFile.wdl" as Step4cSVRmFile


workflow SVCalling {
    
    String capture
    String bam
    String bam_index
    String outdir
    String outprefix
    String annovarDB
    String publicsvDB
    String grandsvDB
    Boolean rmfile
    Int thread
    String docker_image

    
    #String outprefix = sub(basename(bam), ".bam$", "")
    
    call Step4aSniffles.Sniffles as Sniffles {
        input:
            bam = bam,
            bam_index = bam_index,
            outdir = outdir,
            outprefix = outprefix,
            thread = thread,
            docker_image = docker_image
    }
    
    String vcf = Sniffles.sniffles_vcf
    
    call Step4bSVannotation.SVannotation as SVannotation{
        input:
            vcf = vcf,
            outdir = outdir,
            outprefix = outprefix,
            annovarDB = annovarDB,
            publicsvDB = publicsvDB,
            grandsvDB = grandsvDB,
            docker_image = docker_image
    }
    
    
    #if (rmfile) {
    #    call Step4cSVRmFile.SVRmFile as SVRmFile {
    #        input:
    #            outdir = outdir,
    #            outprefix = outprefix,
    #            docker_image = docker_image
    #    }
    #}
    
}