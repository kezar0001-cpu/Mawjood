import { ReactNode } from 'react';

export const Card = ({ title, children }: { title?: string; children: ReactNode }) => (
  <div className="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
    {title && <h3 className="mb-2 text-sm font-semibold text-gray-700">{title}</h3>}
    {children}
  </div>
);
