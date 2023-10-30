models=('Llama-2-7b-hf')
datasets=('flan')
finetunes=('lora')
# optimizers=('AdamW' 'SGD' 'LARS' 'LAMB' 'Lion')
optimizers=('AdamW' 'SGD' 'Lion')
# optimizers=('AdamW')
today=$(TZ=JST-9 date "+%Y-%m-%d")
time=$(TZ=JST-9 date "+%H%M")

quantize='not_quantize'
max_iters=200000

batch_size=('128')
micro_batch_size=('1')
learning_rate=('3e-4' '8e-4' '3e-3')
weight_decay=('0.01')

for dataset in ${datasets[@]}
do
    for finetune in ${finetunes[@]}
    do
        for model in ${models[@]}
        do
            for optimizer in ${optimizers[@]}
            do
                for 
                mkdir -p logs/$model/$dataset/"$finetune"_"$optimizer"/$quantize/$today &&
                if [ $optimizer = 'SAM' ]; then
                    fine='lora_sam'
                else
                    fine=$finetune
                fi
                python finetune/$fine.py \
                --data_dir data/$dataset-$model \
                --checkpoint_dir checkpoints/meta-llama/$model \
                --out_dir out/$model/$dataset/"$finetune"_"$optimizer"/$quantize/$today \
                --precision "bf16-true" \
                --optim_name $optimizer \
                --max_iters $max_iters \
                >logs/$model/$dataset/"$finetune"_"$optimizer"/$quantize/$today/$time.log
            done
        done
    done
done
### 実行するとき
# CUDA_VISIBLE_DEVICES=0 nohup bash sh/llama.sh &