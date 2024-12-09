## Lamarck &nbsp; &nbsp; &nbsp; 2024-10-26
---


*01  序列比对*
```bash
augur align \
--sequences results/sequences.fasta \
--reference-sequence config/pv.gb \
--output results/aligned.fasta \
--fill-gaps
```

*02  建树*
```bash
augur tree \
--alignment results/aligned.fasta \
--output results/tree_raw.nwk \
--nthreads 64
```

*03  推测时间*
```bash
augur refine \
--tree results/tree_raw.nwk \
--alignment results/aligned.fasta \
--metadata data/metadata.tsv \
--output-tree results/tree.nwk \
--output-node-data results/branch_lenths.json \
--timetree \
--coalescent opt \
--date-confidence \
--date-inference marginal \
--clock-filter-iqd 4
```

*04  重建祖先序列特征*
```bash
augur traits \
--tree results/tree.nwk \
--metadata data/metadata.tsv \
--output results/traits.json \
--columns country \
--confidence
```

*05  重建祖先序列*
```bash
augur ancestral \
--tree results/tree.nwk \
--alignment results/aligned.fasta \
--output-node-data results/nt_muts.json \
--inference joint
```

*06  确定氨基酸突变*
```bash
augur translate \
--tree results/tree.nwk \
--ancestral-sequences results/nt_muts.json \
--reference-sequence config/Rabies_virus_reference.gb \
--output results/aa_muts.json
```

*07  导出汇总*
```bash
augur export v2 \
--tree results/tree.nwk \
--metadata data/metadata.tsv \
--node-data results/branch_lenths.json \
results/traits.json \
results/nt_muts.json \
results/aa_muts.json \
--colors config/colors.tsv \
--lat-longs config/lat_longs.tsv \
--auspice-config config/auspice_config.json \
--output auspice/rabies.json
```

*把生成的汇总json文件放在results文件夹中*

*08  结果可视化*
```bash
conda activate auspice
auspice build
auspice view --datasetDir <directory of results>
auspice view --datasetDir /mnt/f/1022/zika-tutorial/auspice_results/
```


##### [完整教程](https://mp.weixin.qq.com/s/ndq4WgUitU_lBcmmoD9eYQ)
