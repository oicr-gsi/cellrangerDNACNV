version 1.0

workflow cellrangerDNACNV {
  input {
    String runID
    String samplePrefix
    String fastqDirectory
    String referenceDirectory
    String? localMem
  }
  call cnv {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = fastqDirectory,
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
    fastqDirectory: "Path to folder containing fastq files."
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

task cnv {
  input {
    String? modules = "cellranger-dna"
	String? cellranger_dna = "cellranger-dna"
    String runID
    String samplePrefix
    String fastqDirectory
    String referenceDirectory
    String? localMem = "2"
  }

  command <<<
   ~{cellranger_dna} cnv \
    --id "~{runID}" \
    --fastq "~{fastqDirectory}" \
    --sample "~{samplePrefix}" \
    --reference "~{referenceDirectory}" \
    --localmem "~{localMem}"
  >>>

  runtime {
    memory: "~{localMem}"
    modules: "~{modules}"
  }

  output {
    File possortedBam = "outs/possorted_bam.bam"
    File possortedBamIndex = "outs/possorted_bam.bam.bai"
    File nodeCNVCalls = "outs/node_cnv_calls.bed"
    File nodeUnmergedCNVCalls = "outs/node_unmerged_cnv_calls.bed"
    File mappableRegions = "outs/mappable_regions.bed"
    File perCellSummaryMetrics = "outs/per_cell_summary_metrics.csv"
    File summary = "outs/summary.csv"
    File cnvData = "outs/cnv_data.h5"
    File dloupe = "outs/dloupe.dloupe"
    File alarmsSummary = "outs/alarms_summary.txt"
  }

   parameter_meta {
      runID: "A unique run ID string."
      samplePrefix: "Sample name (FASTQ file prefix). Can take multiple comma-separated values."
      fastqDirectory: "Path to folder containing fastq files."
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