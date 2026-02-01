"use client";

import { useEffect, useState } from "react";
import type { AccessProfile, UserDivision } from "@/lib/access";

/* ======================================================
   STORAGE
====================================================== */

const KEY = "nca:accessProfile:v1";

const DEFAULT: AccessProfile = {
  userDivision: "phoenix",
  addons: { sentinel: true }, // Phoenix always has Sentinel
};

function safeParse(raw: string | null): AccessProfile | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw);
    if (!v || typeof v !== "object") return null;

    const userDivision = (v.userDivision as UserDivision) || "phoenix";
    const addons =
      v.addons && typeof v.addons === "object" ? v.addons : {};

    return { userDivision, addons };
  } catch {
    return null;
  }
}

/* ======================================================
   REACT HOOK
====================================================== */

export function useAccessProfile() {
  const [mounted, setMounted] = useState(false);
  const [profile, setProfile] = useState<AccessProfile>(DEFAULT);

  useEffect(() => {
    setMounted(true);
    const existing = safeParse(window.localStorage.getItem(KEY));
    if (existing) setProfile(existing);
  }, []);

  function save(next: AccessProfile) {
    setProfile(next);
    try {
      window.localStorage.setItem(KEY, JSON.stringify(next));
    } catch {}
  }

  return {
    mounted,
    profile,
    setUserDivision: (userDivision: UserDivision) =>
      save({ ...profile, userDivision }),
    setSentinelAddOn: (enabled: boolean) =>
      save({
        ...profile,
        addons: { ...profile.addons, sentinel: enabled },
      }),
  };
}

/* ======================================================
   CANON ACCESS CHECK (USED BY AccessGate)
====================================================== */

export type AccessCheck = {
  division?: "phoenix" | "vanguard";
  sentinelOnly?: boolean;
};

export function canAccess(
  profile: AccessProfile,
  rules: AccessCheck = {}
): boolean {
  const { userDivision, addons } = profile;

  // Phoenix = god mode
  if (userDivision === "phoenix") return true;

  // Sentinel-gated content
  if (rules.sentinelOnly) {
    return addons?.sentinel === true;
  }

  // Division gate
  if (rules.division) {
    return userDivision === rules.division;
  }

  return true;
}