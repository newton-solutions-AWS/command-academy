export type UserRole = "founder" | "phoenix" | "vanguard" | "sentinel" | "guest";

export function getUserRole(): UserRole {
  // Later: hook to auth/session. For now, keep it predictable.
  return "founder";
}

export function canAccessDivision(role: UserRole, division: "phoenix" | "vanguard" | "sentinel") {
  if (role === "founder") return true;
  if (role === "phoenix") return true;
  if (role === "vanguard") return division !== "sentinel";
  if (role === "sentinel") return true;
  return division === "phoenix"; // guest gets only Phoenix preview
}
