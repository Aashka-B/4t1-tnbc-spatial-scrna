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

        ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
        logmsg() { printf "[%s] [download_fastq] [sra=%s] %s\n" "$(ts)" "{wildcards.sra}" "$*" >> {log}; }

        tmpdir="$(mktemp -d)"
        trap "rm -rf $tmpdir" EXIT

        # Fetch SRA object to local cache
        logmsg "START"
        logmsg "prefetch starting"
        prefetch {wildcards.sra} >> {log} 2>&1 || { logmsg "ERROR prefetch failed"; exit 1; }

        # Convert to FASTQ, split pairs, write to tmp
        logmsg "fasterq-dump starting"
        echo "[{wildcards.sra}] fasterq-dump..." >> {log}
          || { logmsg "ERROR fasterq-dump failed"; exit 1; }

        # Ensure both mates exist
        if [ ! -s "$tmpdir/{wildcards.sra}_1.fastq" ] || [ ! -s "$tmpdir/{wildcards.sra}_2.fastq" ]; then
          ls -l "$tmpdir" >> {log} 2>&1 || true
          logmsg "ERROR expected paired files not found"
          exit 1
        fi

        # Compress to final outputs
        logmsg "gzip compressing to final outputs"
        gzip -c "$tmpdir/{wildcards.sra}_1.fastq" > {output.r1} 2>> {log}
        gzip -c "$tmpdir/{wildcards.sra}_2.fastq" > {output.r2} 2>> {log}

        logmsg "DONE"
        """
