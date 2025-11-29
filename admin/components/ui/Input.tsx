'use client';

import { InputHTMLAttributes } from 'react';
import clsx from 'clsx';

export const Input: React.FC<InputHTMLAttributes<HTMLInputElement>> = ({ className, ...props }) => {
  return (
    <input
      className={clsx(
        'w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500',
        className,
      )}
      {...props}
    />
  );
};
