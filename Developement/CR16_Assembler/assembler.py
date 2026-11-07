import sys
REGISTERS = {f"R{i}": i for i in range(16)}

"""ADD, ADDU, ADDC, ADDCU,
            SUB, SUBC, MUL,
            AND, OR, XOR, NOT,
            MOV,
            LSH, ALSH:
            ADDI, ADDUI, ADDCI, ADDCUI,
            SUBI, SUBCI, MULI,
            ANDI, ORI, XORI,
            MOVI, LUI,
            LSHI, ASHUI:
            CMP, CMPU
            CMPI, CMPUI
            STOR, SPR
            LOAD, LPR, SNXB, ZRXB
            BCOND
            SCOND, JCOND, JAL, RETX, EXCP
            TBIT, TBITI, DI, EI
"""

# OPcodes bits 15-12
OPCODESMSB = {
# Arithmetic & Logic (Reg-Reg & Immediate)
    "ADD":   0b0000,
    "ADDU":  0b0000,
    "ADDC":  0b0000,
    "ADDCU": "xxxx",  # Not specified in ISA
    "SUB":   0b0000,
    "SUBC":  0b0000,
    "MUL":   0b0000,
    "AND":   0b0000,
    "OR":    0b0000,
    "XOR":   0b0000,
    "NOT":   "xxxx",  # Not specified in ISA
    "MOV":   0b0000,

    # Shifts
    "LSH":   0b1000,
    "ALSH":  0b1000,  # ASHU in ISA 
    
    # Immediate Instructions
    "ADDI":  0b0101, 
    "ADDUI": 0b0110, 
    "ADDCI": 0b0111, 
    "ADDCU": "xxxx",  # Not specified in ISA
    "SUBI":  0b1001, 
    "SUBCI": 0b1010, 
    "MULI":  0b1110, 
    "ANDI":  0b0001, 
    "ORI":   0b0010, 
    "XORI":  0b0011, 
    "MOVI":  0b1101, 
    "LUI":   0b1111, 
    "LSHI":  0b1000, 
    "ASHUI": 0b1000, 
    
    # Comparisons
    "CMP":   0b0000, 
    "CMPU":  "xxxx",  # Not specified in ISA
    "CMPI":  0b1011, 
    "CMPUI": "xxxx",  # Not specified in ISA

    # Memory, System & Control
    "STOR":  0b0100, 
    "SPR":   0b0100, 
    "LOAD":  0b0100, 
    "LPR":   0b0100, 
    "SNXB":  0b0100, 
    "ZRXB":  0b0100, 
    "BCOND": 0b1100, 
    "SCOND": 0b0100, 
    "JCOND": 0b0100, 
    "JAL":   0b0100, 
    "RETX":  0b0100, 
    "EXCP":  0b0100, 
    "TBIT":  0b0100, 
    "TBITI": 0b0100, 
    "DI":    0b0100, 
    "EI":    0b0100, 
}

#opcodes bits 7-4
OPCODESLSB = {
    # Register-to-Register Extensions
    "ADD":   0b0101, 
    "ADDU":  0b0110, 
    "ADDC":  0b0111, 
    "ADDCU": "xxxx",
    "SUB":   0b1001, 
    "SUBC":  0b1010, 
    "MUL":   0b1110, 
    "AND":   0b0001, 
    "OR":    0b0010, 
    "XOR":   0b0011, 
    "NOT":   "xxxx",
    "MOV":   0b1101, 
    
    # Shifts (Extensions)
    "LSH":   0b0100, 
    "ALSH":  0b0110,  # ASHU extension 
    
    # Immediates / Shifts with Immediates (Bits 7-4 hold ImmHi or specific sub-fields)
    "ADDI":  "xxxx",  # Uses ImmHi
    "ADDUI": "xxxx",  # Uses ImmHi
    "ADDCI": "xxxx",  # Uses ImmHi
    "ADDCU": "xxxx",
    "SUBI":  "xxxx",  # Uses ImmHi
    "SUBCI": "xxxx",  # Uses ImmHi
    "MULI":  "xxxx",  # Uses ImmHi
    "ANDI":  "xxxx",  # Uses ImmHi
    "ORI":   "xxxx",  # Uses ImmHi
    "XORI":  "xxxx",  # Uses ImmHi
    "MOVI":  "xxxx",  # Uses ImmHi
    "LUI":   "xxxx",  # Uses ImmHi
    "LSHI":  0b0000,  # Bits 7-6 are 00, bits 5-4 are sign 's' (handled dynamically if needed) 
    "ASHUI": 0b0010,  # Bits 7-6 are 00, bits 5-4 are sign 's' (handled dynamically if needed) 
    
    # Comparisons
    "CMP":   0b1011, 
    "CMPU":  "xxxx",
    "CMPI":  "xxxx",  # Uses ImmHi
    "CMPUI": "xxxx",
    
    # Memory, System & Control Extensions
    "STOR":  0b0100, 
    "SPR":   0b0101, 
    "LOAD":  0b0000, 
    "LPR":   0b0001, 
    "SNXB":  0b0010, 
    "ZRXB":  0b0110, 
    "BCOND": "xxxx",  # Uses condition code bits (cond)
    "SCOND": 0b1101, 
    "JCOND": 0b1100, 
    "JAL":   0b1000, 
    "RETX":  0b1001, 
    "EXCP":  0b1011, 
    "TBIT":  0b1010, 
    "TBITI": 0b1110, 
    "DI":    0b0011, 
    "EI":    0b0111, 

}

#parses the registers in an instructions to their corresponding binary values ex: R4 -> 0100
def parse_register(reg_str):
    clean = reg_str.strip(",").upper()
    if clean in REGISTERS:
        return REGISTERS[clean]
    raise ValueError(f"Invalid register: {reg_str}")

# Translates a single line of assembly text into a 16-bit formatted binary string
def assemble_line(line_num, line_text):
    line = line_text.split(";")[0].strip()
    if not line:
        return None  # Skip blanks/comments
        
    parts = line.replace(",", "").split()
    mnemonic = parts[0].upper()

    if mnemonic not in OPCODESMSB:
        raise ValueError(f"Line {line_num}: Unknown mnemonic '{mnemonic}'")
        
    msb = OPCODESMSB[mnemonic]
    lsb = OPCODESLSB[mnemonic]

    # --- PATTERN A: Register-to-Register Instructions ---
    if isinstance(lsb, int) and mnemonic not in ["LSHI", "ASHUI"]: 
        rsrc = parse_register(parts[1])
        rdest = parse_register(parts[2])
        machine_code = (msb << 12) | (rdest << 8) | (lsb << 4) | rsrc

    # --- PATTERN B: Immediate Instructions ---
    elif mnemonic in ["ADDI", "ADDUI", "ADDCI", "SUBI", "SUBCI", "MULI", "ANDI", "ORI", "XORI", "MOVI", "LUI", "CMPI"]:
        imm_val = int(parts[1])
        rdest = parse_register(parts[2])
        
        imm_byte = imm_val & 0xFF
        imm_hi = (imm_byte >> 4) & 0x0F
        imm_lo = imm_byte & 0x0F
        
        machine_code = (msb << 12) | (rdest << 8) | (imm_hi << 4) | imm_lo

    else:
        raise ValueError(f"Line {line_num}: Instruction format for '{mnemonic}' needs a custom handler.")

    # Convert to a 16-bit binary string first
    bin_str = format(machine_code, '016b')
    
    # Format with underscores between every 4 bits for readability
    formatted_bin = f"{bin_str[0:4]}_{bin_str[4:8]}_{bin_str[8:12]}_{bin_str[12:16]}"
    
    return formatted_bin

def assemble_file(input_filename, output_filename):
    """Reads input .asm file, translates line by line, and writes .mem file for Verilog."""
    machine_code_list = []
    
    print(f"Assembling {input_filename}...")
    with open(input_filename, 'r') as f:
        for line_num, line in enumerate(f, 1):
            try:
                bin_str = assemble_line(line_num, line)
                if bin_str:
                    machine_code_list.append(bin_str)
            except Exception as e:
                print(f"Error on line {line_num}: {e}")
                sys.exit(1)
                
    with open(output_filename, 'w') as f:
        for code in machine_code_list:
            f.write(code + "\n")
            
    print(f"Success! Wrote {len(machine_code_list)} instructions to {output_filename}.")

if __name__ == "__main__":
    # Test execution: reads program.asm and writes program.mem
    assemble_file("program.asm", "program.mem")