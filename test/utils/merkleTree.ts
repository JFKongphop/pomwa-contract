import MerkleTree from "fixed-merkle-tree";

export const createMerkleTree = (treeLevels: number, leaves: any, hash: any) => {
  return new MerkleTree(treeLevels, leaves, {
    hashFunction: (a: any, b: any) => hash([a, b]) as any,
    zeroElement: 0 as any
  });
}