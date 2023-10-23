from subprocess import run
from os.path import exists, getsize
from math import ceil

img = b''

def assemble(path, flags=''):
    out = path.split('.')[0] + '.bin'
    run(f'nasm {path} -fbin {flags} -o {out}'.split())
    print(f'nasm {path} -fbin {flags} -o {out}')
    
    with open(out, 'rb') as file:
        return file.read()

boot1 = assemble('src/x86/boot1.S')
boot0 = assemble('src/x86/boot0.S', f'-DBOOT1_SIZE={ceil(len(boot1)/512)}')

partition_table_header = b'\x45\x46\x49\x20\x50\x41\x52\x54'
partition_table_header += (0).to_bytes(4, 'little')
partition_table_header += (0x5c).to_bytes(4, 'little')
partition_table_header += (0).to_bytes(4, 'little') # Checksum
partition_table_header += (0).to_bytes(4, 'little')
partition_table_header += (1).to_bytes(8, 'little')
partition_table_header += (0xffffffffffffffff).to_bytes(8, 'little')
partition_table_header += (3+ceil(len(boot1)/512)).to_bytes(8, 'little')
partition_table_header += (0xfffffffffffffffe).to_bytes(8, 'little')
partition_table_header += (0).to_bytes(16, 'little')
partition_table_header += (2).to_bytes(8, 'little')
partition_table_header += (1).to_bytes(4, 'little')
partition_table_header += (128).to_bytes(4, 'little')
partition_table_header += (0).to_bytes(4, 'little')
partition_table_header += b'\0' * (512 - len(partition_table_header))

partition_entries = b'\xc1\x2a\x73\x28\xf8\x1f\x11\xd2\xba\x4b\x00\xa0\xc9\x3e\xc9\x3b'
partition_entries += (0).to_bytes(0, 'little')
partition_entries += (3+ceil(len(boot1)/512)).to_bytes(8, 'little')
partition_entries += (0xfffffffffffffffe).to_bytes(8, 'little')
partition_entries += (0b101).to_bytes(8, 'little')
partition_entries += (" " * 16).encode('utf-16-le')
partition_entries += b'\0' * (512 - len(partition_entries))

img += boot0

img += partition_table_header + partition_entries

img += boot1

img += b'\0' * (1474560 - len(img))

with open("boot.img", "wb") as file:
    file.write(img)