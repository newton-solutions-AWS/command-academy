import "./globals.css";
import React from "react";

export const metadata = {
  title: "Newton Command Academy",
  description: "Command UI + ATILS Engine",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
