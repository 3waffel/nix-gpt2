import os
from transformers import BertTokenizer, TFGPT2LMHeadModel, TextGenerationPipeline

max_length = os.environ.get('MAX_LENGTH', 140)
prefix_text = os.environ.get('PREFIX_TEXT', "今天也是好天气")
model_path = os.environ['MODELPATH']

tokenizer = BertTokenizer.from_pretrained(model_path)
model = TFGPT2LMHeadModel.from_pretrained(model_path)

generator = TextGenerationPipeline(model, tokenizer)
outputs = generator(prefix_text, max_length)
for output in outputs:
    print(output)