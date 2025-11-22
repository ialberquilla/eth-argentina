"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export type Category = "all" | "lending" | "perpetuals" | "rwa" | "docs";

interface CategoryMenuProps {
  selectedCategory: Category;
  onCategoryChange: (category: Category) => void;
}

export const CategoryMenu = ({ selectedCategory, onCategoryChange }: CategoryMenuProps) => {
  const pathname = usePathname();

  const categories = [
    { id: "all" as Category, label: "All Products", href: "/" },
    { id: "lending" as Category, label: "Lending", href: "/?category=lending" },
    { id: "perpetuals" as Category, label: "Perpetuals", href: "/?category=perpetuals" },
    { id: "rwa" as Category, label: "Real World Assets", href: "/?category=rwa" },
  ];

  return (
    <nav className="mb-6 border-b border-border">
      <div className="flex gap-1">
        {categories.map((category) => (
          <button
            key={category.id}
            onClick={() => onCategoryChange(category.id)}
            className={`px-4 py-3 text-sm font-medium transition-colors relative ${
              selectedCategory === category.id
                ? "text-primary"
                : "text-muted hover:text-foreground"
            }`}
          >
            {category.label}
            {selectedCategory === category.id && (
              <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />
            )}
          </button>
        ))}
        <Link
          href="/docs"
          className={`px-4 py-3 text-sm font-medium transition-colors relative ${
            pathname === "/docs"
              ? "text-primary"
              : "text-muted hover:text-foreground"
          }`}
        >
          Docs
          {pathname === "/docs" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />
          )}
        </Link>
      </div>
    </nav>
  );
};
