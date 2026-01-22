export type Division = "phoenix" | "vanguard" | "sentinel";

export type Rank =
  | "recruit"
  | "operator"
  | "specialist"
  | "veteran"
  | "sentinel";

export type Clearance =
  | "public"
  | "restricted"
  | "classified"
  | "black";

export const RankOrder: Rank[] = [
  "recruit",
  "operator",
  "specialist",
  "veteran",
  "sentinel",
];

export const ClearanceOrder: Clearance[] = [
  "public",
  "restricted",
  "classified",
  "black",
];

export type AccessProfile = {
  division: Division;
  rank: Rank;
  clearance: Clearance;
  phoenixOverride: boolean;
};

export function rankAtLeast(a: Rank, b: Rank): boolean {
  return RankOrder.indexOf(a) >= RankOrder.indexOf(b);
}

export function clearanceAtLeast(a: Clearance, b: Clearance): boolean {
  return ClearanceOrder.indexOf(a) >= ClearanceOrder.indexOf(b);
}
