// app/layout.tsx

import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Command Academy",
  description: "From Service to Cyber — Command Academy",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, sans-serif",
          backgroundColor: "#050505",
          color: "#e5e5e5",
        }}
      >
        {children}
      </body>
    </html>
  );
}
