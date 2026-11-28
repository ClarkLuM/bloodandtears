import glob, os
from PIL import Image
os.makedirs("art", exist_ok=True)
for f in glob.glob("out/*.*g"):
    im = Image.open(f).convert("RGB"); im.thumbnail((1600, 1600))
    im.save("art/" + os.path.splitext(os.path.basename(f))[0] + ".jpg", quality=82)
