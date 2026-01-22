import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type UserDivision = "phoenix" | "vanguard";
export type AddOns = { sentinel?: boolean };

export type AccessProfile = {
  userDivision: UserDivision;
  addons: AddOns;
};

export function canAccessDivision(profile: AccessProfile, target: Division): boolean {
  if (profile.userDivision === "phoenix") return true; // Phoenix: full unrestricted (includes Vanguard + Sentinel)
  if (target === "phoenix") return false; // Vanguard users cannot access Phoenix
  if (target === "vanguard") return true;
  if (target === "sentinel") return !!profile.addons.sentinel; // Vanguard needs Sentinel add-on
  return false;
}
