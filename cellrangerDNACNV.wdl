version 1.0

workflow cellrangerDNACNV {
  input {
    String runID
    String samplePrefix
    Array[File] fastqs
    String referenceDirectory
    Int? localMem
  }

  call symlinkFastqs {
      input:
        samplePrefix = samplePrefix,
        fastqs = fastqs
    }

  call cnv {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = symlinkFastqs.fastqDirectory,
      referenceDirectory = referenceDirectory,
      localMem = localMem
  }

  output {
    File possortedBam = cnv.possortedBam
    File possortedBamIndex = cnv.possortedBamIndex
    File nodeCNVCalls = cnv.nodeCNVCalls
    File nodeUnmergedCNVCalls = cnv.nodeUnmergedCNVCalls
    File mappableRegions = cnv.mappableRegions
    File perCellSummaryMetrics = cnv.perCellSummaryMetrics
    File summary = cnv.summary
    File cnvData = cnv.cnvData
    File dloupe = cnv.dloupe
    File alarmsSummary = cnv.alarmsSummary
  }

  parameter_meta {
    runID: "A unique run ID string."
    samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
    fastqDirectory: "Path to folder containing symlinked fastq files."
    referenceDirectory: "Path to the Cell Ranger DNA compatible genome reference."
    localMem: "Restricts cellranger-dna to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger-dna will use 90% of the memory available on your system."
  }

  meta {
    author: "Angie Mosquera"
    email: "Angie.Mosquera@oicr.on.ca"
    description: "Workflow to process Chromium single cell DNA sequencing output to align reads, identify copy number variation (CNV), and compare heterogeneity among cells."
    dependencies: []
  }
}

task symlinkFastqs {
  input {
    Array[File] fastqs
    String? samplePrefix
    Int mem = 1
  }

  command <<<
    mkdir ~{samplePrefix}
    while read line ; do
      ln -s $line ~{samplePrefix}/$(basename $line)
    done < ~{write_lines(fastqs)}
    echo $PWD/~{samplePrefix}
  >>>

  runtime {
    memory: "~{mem} GB"
  }

  output {
     String fastqDirectory = read_string(stdout())
  }

  parameter_meta {
    fastqs: "Array of input fastqs."
  }

  meta {
    output_meta: {
      fastqDirectory: "Path to folder containing symlinked fastq files."
    }
  }
}

task cnv {
  input {
    String? modules = "cellranger-dna"
    String? cellranger_dna = "cellranger-dna"
    String runID
    String samplePrefix
    String fastqDirectory
    String referenceDirectory
    Int? localMem = 64
    Int timeout = 48
  }

  command <<<
   ~{cellranger_dna} cnv \
    --id "~{runID}" \
    --fastqs "~{fastqDirectory}" \
    --sample "~{samplePrefix}" \
    --reference "~{referenceDirectory}" \
    --localmem "~{localMem}"
  >>>

  runtime {
    memory: "~{localMem} GB"
    modules: "~{modules}"
    timeout: "~{timeout}"
  }

  output {
    File possortedBam = "~{runID}/outs/possorted_bam.bam"
    File possortedBamIndex = "~{runID}/outs/possorted_bam.bam.bai"
    File nodeCNVCalls = "~{runID}/outs/node_cnv_calls.bed"
    File nodeUnmergedCNVCalls = "~{runID}/outs/node_unmerged_cnv_calls.bed"
    File mappableRegions = "~{runID}/outs/mappable_regions.bed"
    File perCellSummaryMetrics = "~{runID}/outs/per_cell_summary_metrics.csv"
    File summary = "~{runID}/outs/summary.csv"
    File cnvData = "~{runID}/outs/cnv_data.h5"
    File dloupe = "~{runID}/outs/dloupe.dloupe"
    File alarmsSummary = "~{runID}/outs/alarms_summary.txt"
  }

   parameter_meta {
      runID: "A unique run ID string."
      samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
      fastqDirectory: "Path to folder containing symlinked fastq files."
      referenceDirectory: "Path to the Cell Ranger DNA compatible genome reference."
      localMem: "Restricts cellranger-dna to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger-dna will use 90% of the memory available on your system."
      modules: "Environment module name to load before command execution."
    }

  meta {
    output_meta: {
      possortedBam: "Position-sorted BAM.",
      possortedBamIndex: "Position-sorted BAM index.",
      nodeCNVCalls: "CNV calls with imputation.",
      nodeUnmergedCNVCalls: "CNV calls without imputation.",
      mappableRegions: "Highly mappable regions.",
      perCellSummaryMetrics: "Per-cell summary metrics.",
      summary: "Analysis summary metrics.",
      cnvData: "HDF5 file with CNV data.",
      dloupe: "Loupe visualization file.",
      alarmsSummary: "Run alerts."
    }
  }
}
