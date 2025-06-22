const toBytes32 = (bigint) => {
  let hex = bigint.toString(16);
  while (hex.length < 64) hex = '0' + hex;  // pad to 32 bytes (64 hex chars)
  return '0x' + hex;
}

const bytes32ToBigInt = (bytes32hex) => {
  if (bytes32hex.startsWith('0x')) {
    return BigInt(bytes32hex);
  }
  return BigInt('0x' + bytes32hex);
}

module.exports = {
  toBytes32,
  bytes32ToBigInt
}