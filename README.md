# cellranger_dna_cnv

Workflow to process Chromium single cell DNA sequencing output to align reads, identify copy number variation (CNV), and compare heterogeneity among cells.

## Overview

## Usage

### Cromwell
```
java -jar cromwell.jar run cellranger_dna_cnv.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`runID`|String|A unique run ID string.
`samplePrefix`|String|Sample name (FASTQ file prefix). Can take multiple comma-separated values.
`fastqDirectory`|String|Path to folder containing fastq files.
`referenceDirectory`|String|Path to the Cell Ranger DNA compatible genome reference.


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`localMem`|String?|None|Restricts cellranger-dna to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger-dna will use 90% of the memory available on your system.


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`cnv.modules`|String?|"cellranger-dna"|Environment module name to load before command execution.
`cnv.cellranger_dna`|String?|"cellranger-dna"|


### Outputs

Output | Type | Description
---|---|---
`possortedBam`|File|Position-sorted BAM.
`possortedBamIndex`|File|Position-sorted BAM index.
`nodeCNVCalls`|File|CNV calls with imputation.
`nodeUnmergedCNVCalls`|File|CNV calls without imputation.
`mappableRegions`|File|Highly mappable regions.
`perCellSummaryMetrics`|File|Per-cell summary metrics.
`summary`|File|Analysis summary metrics.
`cnvData`|File|HDF5 file with CNV data.
`dloupe`|File|Loupe visualization file.
`alarmsSummary`|File|Run alerts.


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with wdl_doc_gen (https://github.com/oicr-gsi/wdl_doc_gen/)_
