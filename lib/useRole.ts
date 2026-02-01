export type UserRole = "PHOENIX" | "VANGUARD" | "SENTINEL" | "FOUNDER";

export function getUserRole(): UserRole {
  // TEMP: hard-coded until auth is wired
  // Canon doctrine: Phoenix gets full access by default
  return "PHOENIX";
}