"use client";

import { ReactNode, useMemo } from "react";
import { useAccessProfile } from "@/lib/useAccessProfile";

type Props = {
  children: ReactNode;
  division?: "phoenix" | "vanguard";
  sentinelOnly?: boolean;
  fallback?: ReactNode;
};

export default function AccessGate({
  children,
  division,
  sentinelOnly,
  fallback = null,
}: Props) {
  const { mounted, profile } = useAccessProfile();

  const allowed = useMemo(() => {
    if (!mounted) return false;

    const { userDivision, addons } = profile;

    // Phoenix = unrestricted
    if (userDivision === "phoenix") return true;

    // Sentinel-only content
    if (sentinelOnly) {
      return addons?.sentinel === true;
    }

    // Division-gated content
    if (division) {
      return userDivision === division;
    }

    return true;
  }, [mounted, profile, division, sentinelOnly]);

  if (!allowed) return <>{fallback}</>;
  return <>{children}</>;
}