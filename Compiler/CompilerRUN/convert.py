import struct

with open("output.bin", "rb") as f:
    data = f.read()

# Pad to multiple of 4
while len(data) % 4 != 0:
    data += b'\x00'

with open("output_word.hex", "w") as f:
    for i in range(0, len(data), 4):
        word = struct.unpack_from("<I", data, i)[0]  # little-endian 32-bit word
        f.write(f"{word:08X}\n")

print(f"Done. {len(data)//4} words written.")