import struct

bin_file = "market_data.bin"
mem_file = "market_data.mem"

# Read binary file
with open(bin_file, "rb") as f, open(mem_file, "w") as mem_out:
    while chunk := f.read(24):  # 6 float32 per row (24 bytes)
        values = struct.unpack("f f f f f f", chunk)
        # Convert each float to a 32-bit hex value
        hex_values = [format(struct.unpack("<I", struct.pack("<f", v))[0], "08X") for v in values]
        mem_out.write(" ".join(hex_values) + "\n")

print(f"Memory initialization file saved: {mem_file}")
