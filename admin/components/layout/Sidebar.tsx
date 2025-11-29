"use client";

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import clsx from 'clsx';

const links = [
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/dashboard/businesses', label: 'Businesses' },
  { href: '/dashboard/categories', label: 'Categories' },
  { href: '/dashboard/settings', label: 'Settings', disabled: true },
  { href: '/dashboard/analytics', label: 'Analytics', disabled: true },
];

export const Sidebar = () => {
  const pathname = usePathname();

  return (
    <aside className="hidden w-64 flex-shrink-0 border-r border-gray-200 bg-white p-4 md:block">
      <div className="mb-6 text-xl font-bold text-blue-700">Mawjood Admin</div>
      <nav className="space-y-1 text-sm">
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={clsx(
              'flex items-center rounded-md px-3 py-2 font-medium',
              link.disabled
                ? 'cursor-not-allowed text-gray-400'
                : pathname === link.href
                  ? 'bg-blue-50 text-blue-700'
                  : 'text-gray-700 hover:bg-gray-100',
            )}
            aria-disabled={link.disabled}
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
};
