"use client";

import { ReactNode } from "react";
import { useHydrated } from "@/lib/useHydrated";

export function ClientOnly({ children }: { children: ReactNode }) {
  const hydrated = useHydrated();
  if (!hydrated) return null;
  return <>{children}</>;
}