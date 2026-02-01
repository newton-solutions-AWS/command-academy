import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const url = req.nextUrl;
  if (url.pathname.startsWith("/academy")) {
    // HQ must always exist first
    return NextResponse.next();
  }
  return NextResponse.next();
}
