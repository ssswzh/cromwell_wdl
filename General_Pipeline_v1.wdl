import "./bin/Step0.Nanoplexer.wdl" as Step0_Nanoplexer
import "./bin/Step1.Alignment.wdl" as Step1_Alignment
import "./bin/Step2.QualityControl.wdl" as Step2_QualityControl
import "./bin/Step3.SNPCalling.wdl" as Step3_SNPCalling
import "./bin/Step4.SVCalling.wdl" as Step4_SVCalling


# ------------------ #
#      Foreword      #
# ------------------ #

# Author: 
#     zhangsiwen@grandomics.com
# Date: 
#     Oct 31 2019
# Contributions: 
#     I thank Hongshuai Jin (jinhongshuai@grandomics.com) for the original version of Capture Evaluation scripts (check url below) and all assistances and brilliant ideas from GrandOmics R&D department clinical bioinformatics group. I thank IT group for their help in GCS and cloud application, especially Lingxia He and Qing Lei.
# References: 
#     http://gitlab.grandomics.com/hongshuai.jin/capture_wdl
# History:
#     Oct 31 2019, original release version 1.0
#     Nov 14 2019, change all File type to String type for saving storage
#     Nov 21 2019, change all runtime section (docker, memory, cpu)
#     Nov 25 2019, add judgement for deciding the minimum memory for each step since memory/cpu=[2,8]
#     Nov 28 2019, add rmfile.wdl to remove unnecessary files
#     Nov 29 2019, add arguments to seperate three docker images


# ------------------ #
#      Workflow      #
# ------------------ #

workflow General_Pipeline {
	
	# ------------------ #
	#     arguments      #
	# ------------------ #
	
	# inputs
	String fqdir = "fastq_pass"
	String barcode = "barcode.fa"
	String outdir
	String platform = "ont|pb"
	String capture = "/export/home/zhangsiwen/project/1.DMD/DMD_capture_hg19.bed"
	
	# files and parameters configs
	String reference = "/export/home/zhangsiwen/database/hg19/hg19.fa"
	String exon_bed
	String medaka_model = "Available: r941_min_fast, r941_min_high, r941_prom_fast, r941_prom_high, r10_min_high, r941_min_diploid_snp" 

	# run configs
	Boolean rmfile
	Int thread = 16
	String docker_image_base
	String docker_image_clair
	String docker_image_medaka
	
	
	# ------------------ #
	#   Process starts   #
	# ------------------ #
	
	
	# ===== Step 0: Demultiplex ===== #
	
	call Step0_Nanoplexer.Nanoplexer as Nanoplexer {
		input:
			fqdir = fqdir,
			barcode = barcode,
			outdir = outdir,
			thread = thread,
			docker_image = docker_image_base
	}
	# output of Step0_nanoplexer
    Array[File] fastq_list = Nanoplexer.fastq_list # store fastq name list
    
	
	# ===== Run Pipeline For Each Sample ===== #
    scatter (sample in fastq_list) {
        
        String outprefix = basename(sample, ".fastq") # sample_id
        
        
        # ---- Step 1: Alignment ---- #
        
        call Step1_Alignment.Alignment as Alignment {
            input:
                fastq = sample,
                reference = reference,
                outdir = outdir,
                outprefix = outprefix,
                platform = platform,
                thread = thread,
                docker_image = docker_image_base
        }
        # Step 1 outputs: bam and bam.index
        File bam = Alignment.bam
        File bam_index = Alignment.bam_index
        File bam_stat = Alignment.bam_stat
                
    
    	# ---- Step 2: QC ---- #
        
        call Step2_QualityControl.Capture_Evaluation as Capture_Evaluation {
            input:
                capture = capture,
                exon_bed = exon_bed,
                bam = bam,
                bam_index = bam_index,
                bam_stat = bam_stat,
                prefix = outprefix,
                thread = thread,
                outdir = outdir,
                rmfile = rmfile,
                docker_image = docker_image_base
        }
        
        
        # ---- Step 3: SNP Calling and Annotation ---- #
        
        String clair_model = if (platform == "ont") then "fullv3-ont-ngmlr-hg001-hg19/learningRate1e-3.epoch999.learningRate1e-4.epoch1499" else "fullv3-pacbio-ngmlr-hg001+hg002+hg003+hg004-hg19/learningRate1e-3.epoch100.learningRate1e-4.epoch200"
        String clair_threshold = if (platform == "ont") then "0.25" else "0.2"
        
        call Step3_SNPCalling.SNPCalling as SNPCalling {
            input:
                capture = capture,
                bam = bam,
                outdir = outdir,
                clair_model = clair_model,
                medaka_model = medaka_model,
                frequency = clair_threshold,
                reference = reference,
                outprefix = outprefix,
                depth = "4",
                rmfile = rmfile,
                thread = thread,
                docker_image_base = docker_image_base,
                docker_image_clair = docker_image_clair,
                docker_image_medaka = docker_image_medaka
        }
        
        
        # ---- Step 4: SV Calling and Annotation ---- #
        
        call Step4_SVCalling.SVCalling as SVCalling {
            input:
                capture = capture,
                bam = bam,
                bam_index = bam_index,
                outdir = outdir,
                outprefix = outprefix,
                rmfile = rmfile,
                thread = thread,
                docker_image = docker_image_base
        }
        
        
    }
	
	# scatter for each sample finish
	
	
	
	
	
	
	
	
}