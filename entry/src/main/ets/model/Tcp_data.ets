class GlobalData {
  private static instance: GlobalData;
  public fourDigitString: string = '0000';

  private constructor() {}

  static getInstance(): GlobalData {
    if (!GlobalData.instance) {
      GlobalData.instance = new GlobalData();
    }
    return GlobalData.instance;
  }

  modifyDigit(index: number, digit: string) {
    if (index >= 0 && index < 4 && /^\d$/.test(digit)) {
      const arr = this.fourDigitString.split('');
      arr[index] = digit;
      this.fourDigitString = arr.join('');
    }
    console.log("tcp_data = ",this.fourDigitString)
  }
}

export default GlobalData;
