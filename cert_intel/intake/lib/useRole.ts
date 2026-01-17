"use client";

import { useMemo } from "react";

export type DivisionRole = "vanguard" | "phoenix" | "sentinel";

interface RoleContext {
  role: DivisionRole;
  isPhoenix: boolean;
  isSentinel: boolean;
  isVanguard: boolean;
}

/**
 * Canonical role resolver.
 * Source of truth for division-based gating.
 */
export function useRole(division?: string): RoleContext {
  const role = useMemo<DivisionRole>(() => {
    if (!division) return "vanguard";

    const d = division.toLowerCase();

    if (d === "phoenix") return "phoenix";
    if (d === "sentinel") return "sentinel";

    return "vanguard";
  }, [division]);

  return {
    role,
    isPhoenix: role === "phoenix",
    isSentinel: role === "sentinel",
    isVanguard: role === "vanguard",
  };
}