#syntax: OPCODE RS2 RS1 RD
#syntax: SIGNED_INTEGER_OPCODE RS3 RS2 RS1 RD
import os
OPCODE_MAP = {
    "NOP": 0b0000,
    "SLHI": 0b0001,
    "AU": 0b0010,
    "CNT1H": 0b0011,
    "AHS": 0b0100,
    "AND": 0b0101,
    "BCW": 0b0110,
    "MAXWS": 0b0111,
    "MINWS": 0b1000,
    "MLHU": 0b1001,
    "MLHCU": 0b1010,
    "OR": 0b1011,
    "CLZH": 0b1100,
    "RLH": 0b1101,
    "SFWU": 0b1110,
    "SFHS": 0b1111,
    "LI": 0b0000, # LI : Load Immediate special case
    "IAL": 0b000, # IAL : Signed Integer Multiply-Add Low with Saturation
    "IAH": 0b001, # IAH : Signed Integer Multiply-Add High with Saturation
    "ISL": 0b010, # ISL : Signed Integer Multiply-Subtract Low with Saturation
    "ISH": 0b011, # ISH : Signed Integer Multiply-Subtract High with Saturation
    "LAL": 0b100, # LAL : Signed Long Multiply-Add Low with Saturation
    "LAH": 0b101, # LAH : Signed Long Multiply-Add High with Saturation
    "LSL": 0b110, # LSL : Signed Long Multiply-Subtract Low with Saturation
    "LSH": 0b111, # LSH : Signed Long Multiply-Subtract High with Saturation
}

def assemble_instructions(instruction):
    parts = instruction.split()
    if len(parts) < 1:
        raise ValueError("Invalid instruction")
    
    opcode = OPCODE_MAP.get(parts[0].upper())
    if opcode is None:
        raise ValueError(F"Invalid opcode: {parts[0]}")
    
    if parts[0].upper() in ["IAL", "IAH", "ISL", "ISH", "LAL", "LAH", "LSL", "LSH"]:
        if len(parts) != 5:
            raise ValueError("IAL instruction requires 3 registers")
        binary_instruction = format(opcode, '03b')  # Convert opcode to 8-bit binary string

        rs3 = int(parts[1]) & 0b11111
        rs2 = int(parts[2]) & 0b11111
        rs1 = int(parts[3]) & 0b11111
        rd = int(parts[4]) & 0b11111
        binary_instruction = "10"+ binary_instruction + format(rs3, '05b') + format(rs2, '05b') + format(rs1, '05b') + format(rd, '05b')

    elif parts[0].upper() == "LI":
        if len(parts) != 4:
            raise ValueError("LI instruction requires 3 parts")
        load_index = int(parts[1]) & 0b111 # Mask to 3 bits for a 3 bit load index value
        immediate = int(parts[2]) & 0xFFFF # Mask to 16 bits for an 16-bit immediate value
        rd = int(parts[3]) & 0b11111 # Mask to 5 bits for a 5-bit register
        binary_instruction = "0" + format(load_index, '03b') + format(immediate, '016b') + format(rd, '05b') # LI format
    else:
        binary_instruction = format(opcode, '08b')  # Convert opcode to 8-bit binary string
        rs1 = rs2 = rd = 0b00000
        
        if len(parts) > 1:
            rs2 = int(parts[1]) & 0b11111  # Mask to 5 bits for a 5-bit register
        if len(parts) > 2:
            rs1 = int(parts[2]) & 0b11111
        if len(parts) > 3:
            rd = int(parts[3]) & 0b11111
        
        binary_instruction = "11" + binary_instruction + format(rs2, '05b') + format(rs1, '05b') + format(rd, '05b')   # R3 format
    return binary_instruction
script_dir = os.path.dirname(__file__)
file_path = os.path.join(script_dir, 'instructions.txt')
output_file_path = os.path.join(script_dir, 'output_instructions.txt')
def load_instructions(file_path):
    with open(file_path, 'r') as file:
        return [assemble_instructions(line) for line in file.readlines()]
    
def write_buffer_to_file(buffer, output_file_path):
    with open(output_file_path, 'w') as file:
        for instruction in buffer:
            file.write(instruction + '\n')
            

def main():
    buffer = load_instructions(file_path)
    write_buffer_to_file(buffer, output_file_path)
    print("Done!")

if __name__ == "__main__":
    main()
