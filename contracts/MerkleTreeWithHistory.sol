// https://tornado.cash
/*
 * d888888P                                           dP              a88888b.                   dP
 *    88                                              88             d8'   `88                   88
 *    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
 *    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
 *    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
 *    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
 * ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IHasher {
  function poseidon(uint[2] memory inputs) external pure returns (uint);
}

contract MerkleTreeWithHistory {
  uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
  uint256 public constant ZERO_VALUE = 0;
  IHasher public immutable hasher;

  uint32 public levels;

  // the following variables are made public for easier testing and debugging and
  // are not supposed to be accessed in regular code

  // filledSubtrees and roots could be bytes32[size], but using mappings makes it cheaper because
  // it removes index range check on every interaction
  mapping(uint256 => bytes32) public filledSubtrees;
  mapping(uint256 => bytes32) public roots;
  uint32 public constant ROOT_HISTORY_SIZE = 30;
  uint32 public currentRootIndex = 0;
  uint32 public nextIndex = 0;

  mapping(uint256 => mapping(uint256 => bytes32)) public tree; // level => index => node


  constructor(uint32 _levels, IHasher _hasher) {
    require(_levels > 0, "_levels should be greater than zero");
    require(_levels < 32, "_levels should be less than 32");
    levels = _levels;
    hasher = _hasher;

    for (uint32 i = 0; i < _levels; i++) {
      filledSubtrees[i] = zeros(i);
    }

    roots[0] = zeros(_levels);
  }

  /**
   * @dev Hash 2 tree leaves, returns Poseidon(_left, _right)
   */
  function hashLeftRight(
    IHasher _hasher,
    bytes32 _left,
    bytes32 _right
  ) public pure returns (bytes32) {
    require(
      uint256(_left) < FIELD_SIZE,
      "_left should be inside the field"
    );
    require(
      uint256(_right) < FIELD_SIZE,
      "_right should be inside the field"
    );
    uint256 R = uint256(_right);
    uint256 L = uint256(_left);
    return bytes32(_hasher.poseidon([L, R]));
  }

  function _insert(bytes32 _leaf) internal returns (uint32 index) {
    uint32 _nextIndex = nextIndex;
    require(
      _nextIndex != uint32(2) ** levels,
      "Merkle tree is full. No more leaves can be added"
    );
    uint32 currentIndex = _nextIndex;
    bytes32 currentLevelHash = _leaf;
    bytes32 left;
    bytes32 right;

    tree[0][currentIndex] = _leaf;

    for (uint32 i = 0; i < levels; i++) {
      if (currentIndex % 2 == 0) {
        left = currentLevelHash;
        right = zeros(i);
        filledSubtrees[i] = currentLevelHash;
      } else {
        left = filledSubtrees[i];
        right = currentLevelHash;
      }
      currentLevelHash = hashLeftRight(hasher, left, right);
      currentIndex /= 2;

      tree[i + 1][currentIndex] = currentLevelHash;
    }

    uint32 newRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
    currentRootIndex = newRootIndex;
    roots[newRootIndex] = currentLevelHash;
    nextIndex = _nextIndex + 1;
    return _nextIndex;
  }

  /**
   * @dev Whether the root is present in the root history
   */
  function isKnownRoot(bytes32 _root) public view returns (bool) {
    if (_root == 0) {
      return false;
    }
    uint32 _currentRootIndex = currentRootIndex;
    uint32 i = _currentRootIndex;
    do {
      if (_root == roots[i]) {
        return true;
      }
      if (i == 0) {
        i = ROOT_HISTORY_SIZE;
      }
      i--;
    } while (i != _currentRootIndex);
    return false;
  }

  /**
   * @dev Returns the last root
   */
  function getLastRoot() public view returns (bytes32) {
    return roots[currentRootIndex];
  }

  uint256 internal constant Z_0 = 19014214495641488759237505126948346942972912379615652741039992445865937985820;
  uint256 internal constant Z_1 = 10447686833432518214645507207530993719569269870494442919228205482093666444588;
  uint256 internal constant Z_2 = 2186774891605521484511138647132707263205739024356090574223746683689524510919;

  function zeros(uint256 index) public pure returns (bytes32) {
    if (index == 0) return bytes32(Z_0);
    if (index == 1) return bytes32(Z_1);
    if (index == 2) return bytes32(Z_2);
    revert("WrongDefaultZeroIndex");
  }
}