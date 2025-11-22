import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Vault Dashboard",
  description: "Explore and allocate capital to DeFi vaults",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
