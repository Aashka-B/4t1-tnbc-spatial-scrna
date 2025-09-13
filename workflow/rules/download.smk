# workflow/rules/download.smk

rule download_fastq:
    threads: 4
    """
    Download paired-end FASTQs for one SRA run with SRA Toolkit.
    - Uses prefetch + fasterq-dump (split pairs, threaded)
    - Compresses to .fastq.gz
    - Logs: logs/download_{sra}.log
    """
    output:
        r1 = "data/raw/{sra}_1.fastq.gz",
        r2 = "data/raw/{sra}_2.fastq.gz"
    log:
        "logs/download_{sra}.log"
    shell:
        r"""
        set -euo pipefail
        mkdir -p data/raw

        ts() ( date -u +"%Y-%m-%dT%H:%M:%SZ" )

        printf "[%s] [download_fastq] [sra={wildcards.sra}] START\n" "$(ts)" >> {log}

        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT

        printf "[%s] [download_fastq] [sra={wildcards.sra}] prefetch starting\n" "$(ts)" >> {log}
        if ! prefetch {wildcards.sra} >> {log} 2>&1; then
          printf "[%s] [download_fastq] [sra={wildcards.sra}] ERROR prefetch failed\n" "$(ts)" >> {log}
          exit 1
        fi

        printf "[%s] [download_fastq] [sra={wildcards.sra}] fasterq-dump starting\n" "$(ts)" >> {log}
        if ! fasterq-dump --split-files --threads {threads} -O "$tmpdir" {wildcards.sra} >> {log} 2>&1; then
          printf "[%s] [download_fastq] [sra={wildcards.sra}] ERROR fasterq-dump failed\n" "$(ts)" >> {log}
          exit 1
        fi

        # Validate paired outputs
        if [ ! -s "$tmpdir/{wildcards.sra}_1.fastq" ] || [ ! -s "$tmpdir/{wildcards.sra}_2.fastq" ]; then
          ls -l "$tmpdir" >> {log} 2>&1 || true
          printf "[%s] [download_fastq] [sra={wildcards.sra}] ERROR expected paired files not found\n" "$(ts)" >> {log}
          exit 1
        fi

        printf "[%s] [download_fastq] [sra={wildcards.sra}] gzip compressing to final outputs\n" "$(ts)" >> {log}
        gzip -c "$tmpdir/{wildcards.sra}_1.fastq" > {output.r1} 2>> {log}
        gzip -c "$tmpdir/{wildcards.sra}_2.fastq" > {output.r2} 2>> {log}

        printf "[%s] [download_fastq] [sra={wildcards.sra}] DONE\n" "$(ts)" >> {log}
        """
