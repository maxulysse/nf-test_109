include { FASTQC } from './modules/nf-core/fastqc/main.nf'
include { MD5SUM } from './modules/nf-core/md5sum/main.nf'

workflow MAIN {
    take:

    main:
    input = Channel.fromPath(params.test_data['sarscov2']['illumina']['test_1_fastq_gz']).map{ it -> [ [ id:'test_pair' ], it ] }
        .join(Channel.fromPath(params.test_data['sarscov2']['illumina']['test_2_fastq_gz']).map{ it -> [ [ id:'test_pair' ], it ] })
        .map{ meta, fastq_1, fastq_2 -> [ meta + [single_end: false], [fastq_1, fastq_2] ] }

    FASTQC(input)
    MD5SUM(input.map{ meta, files -> files }.flatten().map{ file -> [ [id:file.baseName], file ] })

    emit:
    expected_files = FASTQC.out.zip.mix(MD5SUM.out.checksum)
    versions       = FASTQC.out.versions.first().mix(MD5SUM.out.versions.first())
}

workflow {
    MAIN()
}