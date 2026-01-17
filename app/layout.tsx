import "./globals.css";

export const metadata = {
  title: "Newton Command Academy",
  description: "Executable Reality Command Interface",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-black text-neutral-200">
        {children}
      </body>
    </html>
  );
}
