import "./bin/Step3a.Format_Region.wdl" as Step3aFormatRegion
import "./bin/Step3b.Clairvoyante.wdl" as Step3bClairvoyante
import "./bin/Step3c.Medaka_Variant.wdl" as Step3cMedakaVariant
import "./bin/Step3d.Merge_Vcf.wdl" as Step3dMergeVcf
import "./bin/Step3e.Annotate_Vcf.wdl" as Step3eAnnotateVcf
import "./bin/Step3f.SNP_RmFile.wdl" as Step3fRmFile

workflow SNPCalling {
    
    String capture
    String bam
    String outdir
    String clair_model
    String medaka_model
    String frequency
    String reference
    String outprefix
    String depth
    String annovarDB
    Boolean rmfile
    Int thread
    String docker_image_base
    String docker_image_clair
    String docker_image_medaka
    

    #String outprefix = sub(basename(bam), ".bam$", "")
    
    # *** Step 3a: Format Region ***#
    
    #call Step3aFormatRegion.FormatRegion as FormatRegion {
    #    input:
    #        capture = capture,
    #        outdir = outdir,
    #        outprefix = outprefix,
    #        docker_image = docker_image_base
    #}
    
    #Array[String] region_list = FormatRegion.region
    Array[Array[String]] capture_tsv = read_tsv(capture)
    
    
    # *** Step 3b: Clairvoyante ***#
    
    scatter (region in capture_tsv) {
        call Step3bClairvoyante.Clairvoyante as Clairvoyante {
            input:
                bam = bam,
                region = region,
                model = clair_model,
                frequency = frequency,
                reference = reference,
                outdir = outdir,
                outprefix = outprefix,
                depth = depth,
                thread = thread,
                docker_image = docker_image_clair
        }
    }
    
    Array[String] clair_vcf_Strings = Clairvoyante.clair_vcf
    
    
    # *** Step 3c: Medaka Variant ***#
    
    scatter (region in capture_tsv) {
        call Step3cMedakaVariant.MedakaVariant as MedakaVariant {
            input:
                bam = bam,
                reference = reference,
                region = region,
                outdir = outdir,
                outprefix = outprefix,
                medaka_model = medaka_model,
                thread = thread,
                docker_image = docker_image_medaka
        }
    }
    
    Array[String] medaka_vcf_Strings = MedakaVariant.vcf_String
    
    
    # *** Step 3d: Merge Vcf ***#
    
    call Step3dMergeVcf.MergeVcf as MergeVcfClair {
        input:
            outdir = outdir,
            outprefix = outprefix,
            software = "clair",
            vcf_String_list = clair_vcf_Strings,
            docker_image = docker_image_base
    }
    
    String clair_vcf = MergeVcfClair.merged_vcf
    
    call Step3dMergeVcf.MergeVcf as MergeVcfMedaka {
        input:
            outdir = outdir,
            outprefix = outprefix,
            software = "medaka",
            vcf_String_list = medaka_vcf_Strings,
            docker_image = docker_image_base
    }
    
    String medaka_vcf = MergeVcfMedaka.merged_vcf
    
    
    # *** Step 3e: Annotate Vcf ***#
    
    call Step3eAnnotateVcf.AnnotateVcf as AnnotateVcfClair {
        input:
            vcf = clair_vcf,
            outprefix = outprefix,
            outdir = outdir,
            software = "clair",
            annovarDB = annovarDB,
            docker_image = docker_image_base,
            thread = thread
    }
    
    call Step3eAnnotateVcf.AnnotateVcf as AnnotateVcfMedaka {
        input:
            vcf = medaka_vcf,
            outprefix = outprefix,
            outdir = outdir,
            software = "medaka",
            annovarDB = annovarDB,
            docker_image = docker_image_base,
            thread = thread
    }
    
    
    #if (rmfile) {
    #    call Step3fRmFile.SNPRmFile as SNPRmFile {
    #        input:
    #            outprefix = outprefix,
    #            outdir = outdir,
    #            docker_image = docker_image_base
    #    }
    #}
    
}