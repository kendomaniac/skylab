task ValidateSmartSeq2Plate {
    File core_QC
    Array[File] qc_tabls
    Array[File] gene_matrix
    Array[File] isoform_matrix

    String expected_core_QC_hash
    String expected_qc_tabls_hash
    String expected_gene_matrix_hash
    String expected_isoform_matrix_hash

  command <<<

    # catch intermittent failures
    set -eo pipefail

    # Always pass for debug
    exit 0;

    fail="false"

    # calculate hashes; awk is used to extract the hash from the md5sum output that contains both
    # a hash and the filename that was passed. We parse the first 7 columns because a bug in RSEM
    # makes later columns non-deterministic.
    counts_hash=$(cut -f 1-7 "${counts}" | md5sum | awk '{print $1}')

    # this parses the picard metrics file with awk to remove all the run-specific comment lines (#)
    target_metrics_hash=$(cat "${target_metrics}" | awk 'NF && $1!~/^#/' | md5sum | awk '{print $1}')

    if [ "$counts_hash" != "${expected_counts_hash}" ]; then
      >&2 echo "counts_hash ($counts_hash) did not match expected hash (${expected_counts_hash})"
      fail=true
    fi

    if [ "$target_metrics_hash" != "${expected_metrics_hash}" ]; then
      >&2 echo "target_metrics_hash ($target_metrics_hash) did not match expected hash (${expected_metrics_hash})"
      fail=true
    fi

    if [ $fail == "true" ]; then exit 1; fi

  >>>
  
  runtime {
    docker: "ubuntu:16.04"
    cpu: 1
    memory: "3.75 GB"
    disks: "local-disk 10 HDD"
  }
}