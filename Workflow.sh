#!/bin/bash

# 激活必要的环境
source activate auspice  # 确保conda环境存在

# 定义路径和参数
SEQUENCES="results/sequences.fasta"
REFERENCE="config/pv.gb"
ALIGNED="results/aligned.fasta"
TREE_RAW="results/tree_raw.nwk"
METADATA="data/metadata.tsv"
TREE="results/tree.nwk"
BRANCH_LENGTHS="results/branch_lenths.json"
TRAITS="results/traits.json"
NT_MUTS="results/nt_muts.json"
AA_MUTS="results/aa_muts.json"
COLORS="config/colors.tsv"
LAT_LONGS="config/lat_longs.tsv"
AUSPICE_CONFIG="config/auspice_config.json"
RESULT_JSON="auspice/rabies.json"
RESULTS_DIR="results"
AUSPICE_RESULTS_DIR="/mnt/f/1022/zika-tutorial/auspice_results/10"

# 01. 序列比对
echo "Running augur align..."
augur align \
    --sequences $SEQUENCES \
    --reference-sequence $REFERENCE \
    --output $ALIGNED \
    --fill-gaps
echo "Sequence alignment completed."

# 02. 建树
echo "Running augur tree..."
augur tree \
    --alignment $ALIGNED \
    --output $TREE_RAW \
    --nthreads 64
echo "Tree construction completed."

# 03. 推测时间
echo "Running augur refine..."
augur refine \
    --tree $TREE_RAW \
    --alignment $ALIGNED \
    --metadata $METADATA \
    --output-tree $TREE \
    --output-node-data $BRANCH_LENGTHS \
    --timetree \
    --coalescent opt \
    --date-confidence \
    --date-inference marginal \
    --clock-filter-iqd 4
echo "Time inference completed."

# 04. 重建祖先序列特征
echo "Running augur traits..."
augur traits \
    --tree $TREE \
    --metadata $METADATA \
    --output $TRAITS \
    --columns country \
    --confidence
echo "Reconstructed ancestral traits."

# 05. 重建祖先序列
echo "Running augur ancestral..."
augur ancestral \
    --tree $TREE \
    --alignment $ALIGNED \
    --output-node-data $NT_MUTS \
    --inference joint
echo "Reconstructed ancestral sequences."

# 06. 确定氨基酸突变
echo "Running augur translate..."
augur translate \
    --tree $TREE \
    --ancestral-sequences $NT_MUTS \
    --reference-sequence $REFERENCE \
    --output $AA_MUTS
echo "Identified amino acid mutations."

# 07. 导出汇总
echo "Running augur export..."
augur export v2 \
    --tree $TREE \
    --metadata $METADATA \
    --node-data $BRANCH_LENGTHS \
               $TRAITS \
               $NT_MUTS \
               $AA_MUTS \
    --colors $COLORS \
    --lat-longs $LAT_LONGS \
    --auspice-config $AUSPICE_CONFIG \
    --output $RESULT_JSON
mv $RESULT_JSON $RESULTS_DIR/
echo "Exported summary JSON and moved to results directory."

# 08. 结果可视化
echo "Visualizing results with Auspice..."
auspice build
auspice view --datasetDir $RESULTS_DIR
auspice view --datasetDir $AUSPICE_RESULTS_DIR
echo "Visualization completed."

echo "Pipeline completed successfully!"
