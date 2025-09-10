# workflow/rules/qc.smk

rule fastqc:
    threads: 4
    """
    FastQC per SRA (both mates).
    Logs -> logs/fastqc_{sra}.log
    """
    input:
        r1 = "data/raw/{sra}_1.fastq.gz",
        r2 = "data/raw/{sra}_2.fastq.gz"
    output:
        directory("results/qc/fastqc/{sra}")
    log:
        "logs/fastqc_{sra}.log"
    shell:
        r"""
        set -euo pipefail
        ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
        logmsg() { printf "[%s] [fastqc] [sra=%s] %s\n" "$(ts)" "{wildcards.sra}" "$*" >> {log}; }

        mkdir -p {output}
        logmsg "START"
        fastqc -t {threads} -o {output} {input.r1} {input.r2} >> {log} 2>&1
        logmsg "DONE"
        """

# Note: SRA_IDS defined in workflow/Snakefile
rule multiqc:
    input:
        expand("results/qc/fastqc/{sra}", sra=SRA_IDS)  # ensure FastQC runs for all
    output:
        "results/qc/multiqc/multiqc_report.html"
    log:
        "logs/multiqc.log"
    shell:
        r"""
        set -euo pipefail
        ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
        logmsg() { printf "[%s] [multiqc] %s\n" "$(ts)" "$*" >> {log}; }

        mkdir -p results/qc/multiqc
        logmsg "START"
        multiqc -o results/qc/multiqc results/qc/fastqc >> {log} 2>&1
        logmsg "DONE"
        """
