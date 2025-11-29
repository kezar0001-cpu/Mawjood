import { ReactNode } from 'react';

export const Table = ({ children }: { children: ReactNode }) => (
  <div className="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
    <table className="min-w-full divide-y divide-gray-200 text-sm">{children}</table>
  </div>
);

export const THead = ({ children }: { children: ReactNode }) => (
  <thead className="bg-gray-50 text-left text-xs font-semibold uppercase text-gray-500">{children}</thead>
);

export const TBody = ({ children }: { children: ReactNode }) => (
  <tbody className="divide-y divide-gray-200 bg-white text-gray-800">{children}</tbody>
);

export const TH = ({ children }: { children: ReactNode }) => <th className="px-4 py-3">{children}</th>;

export const TR = ({ children, className }: { children: ReactNode; className?: string }) => (
  <tr className={className}>{children}</tr>
);

export const TD = ({ children }: { children: ReactNode }) => <td className="px-4 py-3 align-middle">{children}</td>;
