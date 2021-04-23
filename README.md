# General_Pipeline_clin-med

1st version of general pipeline, containing all steps needed for analyzing SNV and SV for captured ONT/PB data.


# Note: 

1. All cromwell files are in folder bin/, all scripts are in foler src/. And scripts are in /usr/local/bin/ in docker image mentioned in the test_input.json file. 

2. Dockerfile is [here](http://gitlab.grandomics.com/siwen.zhang/pipelinebase) written by Siwen Zhang. Remember to push image to cloud then use in Hanwell pipeline, swr.cn-north-1.myhuaweicloud.com/grand-med-clinical/pipeline_base:latest.

3. **File path in input.json could be obs path or sfs path**. If using sfs path, use /sfs/project/path **instead of** /sfs-grand-med-clinical/project/path/ or /sfs-grand-med-research/project/path/ in input.json file.

4. memory/cpu in range of [2-8].

5. task name CAN NOT have underscore (aka '_'), while, you can use '-' or '.', and must start and end with an alphanumeric character.

6. to call environment varible in docker image and use it in task command, use $var instead of ${var}. ${var} will be checked by cromwell and replace it with task input. and $var will be fully kept to the script generated by cromwell.

7. boolean type input in json file should not have quote (aka "), for instance,
`"General_Pipeline.rmfile": true` instead of `"General_Pipeline.rmfile": "true"`



# Usage:

## Example:

All the test files are in /sfs-grand-med-clinical/project/test_docker_pipeline .

## Using GCS

To know gcs usage and environment, please check this [url](http://wiki.grandomics.com/pages/viewpage.action?pageId=3015302) 

Run from ecs-grandomics-medical-01 using gcs env 'gcs-env-grand-med-clinical':

```
~/gcs sub wdl /home/zhangsw/project/general_pipeline_clin-med/General_Pipeline_v1.wdl \
-i /sfs-grand-med-clinical/project/test_docker_pipeline/test_input.json \
-o /home/zhangsw/project/general_pipeline_clin-med/cci.options \
-d /home/zhangsw/project/general_pipeline_clin-med/bin.zip \
-n General_pipeline_test1 \
-s gcs-env-grand-med-clinical
```

## Using Java:

`java -jar /home/zhangsw/cromwell/cromwell.jar run --inputs input.json General_Pipeline_v1.wdl`

To validate pipeline:

`java -jar /home/zhangsw/cromwell/womtool.jar validate General_Pipeline_v1.wdl`

To generate input.json file, run

`java -jar /home/zhangsw/cromwell/womtool.jar inputs General_Pipeline_v1.wdl`



# Steps

Step0, demultiplex according to barcode.fa ([nanoplexer](http://gitlab.grandomics.com/Marvin42/nanoplexer), default memory=32G)

Step1, align reads against reference ([minimap2](https://github.com/lh3/minimap2), default memory=16G)

Step2, quality control of data ([mosdepth](https://github.com/brentp/mosdepth), default memory=16G)

Step3, SNP calling and annotation ([clairvoyante](https://github.com/aquaskyline/Clairvoyante) (default memory=32G), [medaka_variant](https://nanoporetech.github.io/medaka/) (default memory=32G), [annovar](http://annovar.openbioinformatics.org/en/latest/) (default memory=8G))

Step4, SV calling and annotation ([sniffles](https://github.com/fritzsedlazeck/Sniffles) (default memory=16G), SV_anno (default memory=8G))


