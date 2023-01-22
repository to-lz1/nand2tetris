require './code'


describe "code" do

  describe "dest" do
    it 'converts nil to 000' do
      result = Code.dest(nil)
      expect(result).to eq(0b000)
    end

    it 'converts M' do
      result = Code.dest('M')
      expect(result).to eq(0b001)
    end

    it 'converts D' do
      result = Code.dest('D')
      expect(result).to eq(0b010)
    end

    it 'converts A' do
      result = Code.dest('A')
      expect(result).to eq(0b100)
    end

    it 'converts MD' do
      result = Code.dest('MD')
      expect(result).to eq(0b011)
    end

    it 'converts AM' do
      result = Code.dest('AM')
      expect(result).to eq(0b101)
    end

    it 'converts AD' do
      result = Code.dest('AD')
      expect(result).to eq(0b110)
    end

    it 'converts ADM' do
      result = Code.dest('ADM')
      expect(result).to eq(0b111)
    end

    it 'raise error for unexpected input' do
      expect {
        Code.dest('X')
      }.to raise_error(ArgumentError)
    end
  end

  describe 'comp' do
    it 'converts mnemonic to binary (a-bit is 0)', :aggregate_failures do
      expect(Code.comp('0')).to eq(0b0101010)
      expect(Code.comp('1')).to eq(0b0111111)
      expect(Code.comp('-1')).to eq(0b0111010)
      expect(Code.comp('D')).to eq(0b0001100)
      expect(Code.comp('A')).to eq(0b0110000)
      expect(Code.comp('!D')).to eq(0b0001101)
      expect(Code.comp('!A')).to eq(0b0110001)
      expect(Code.comp('-D')).to eq(0b0001111)
      expect(Code.comp('-A')).to eq(0b0110011)
      expect(Code.comp('D+1')).to eq(0b0011111)
      expect(Code.comp('A+1')).to eq(0b0110111)
      expect(Code.comp('D-1')).to eq(0b0001110)
      expect(Code.comp('A-1')).to eq(0b0110010)
      expect(Code.comp('D+A')).to eq(0b0000010)
      expect(Code.comp('D-A')).to eq(0b0010011)
      expect(Code.comp('A-D')).to eq(0b0000111)
      expect(Code.comp('D&A')).to eq(0b0000000)
      expect(Code.comp('D|A')).to eq(0b0010101)
    end

    it 'converts mnemonic to binary (a-bit is 1)', :aggregate_failures do
      expect(Code.comp('M')).to eq(0b1110000)
      expect(Code.comp('!M')).to eq(0b1110001)
      expect(Code.comp('-M')).to eq(0b1110011)
      expect(Code.comp('M+1')).to eq(0b1110111)
      expect(Code.comp('M-1')).to eq(0b1110010)
      expect(Code.comp('D+M')).to eq(0b1000010)
      expect(Code.comp('D-M')).to eq(0b1010011)
      expect(Code.comp('M-D')).to eq(0b1000111)
      expect(Code.comp('D&M')).to eq(0b1000000)
      expect(Code.comp('D|M')).to eq(0b1010101)
    end

    it 'raise error for unexpected input' do
      expect {
        Code.comp('X')
      }.to raise_error(ArgumentError)
    end
  end

  describe "jmp" do
    it "converts mnemonic to binary", :aggregate_failures do
      expect(Code.jump(nil)).to eq(0b000)
      expect(Code.jump('JGT')).to eq(0b001)
      expect(Code.jump('JEQ')).to eq(0b010)
      expect(Code.jump('JGE')).to eq(0b011)
      expect(Code.jump('JLT')).to eq(0b100)
      expect(Code.jump('JNE')).to eq(0b101)
      expect(Code.jump('JLE')).to eq(0b110)
      expect(Code.jump('JMP')).to eq(0b111)
    end
  end
end
