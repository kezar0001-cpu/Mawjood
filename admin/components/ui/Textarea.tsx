'use client';

import { TextareaHTMLAttributes } from 'react';
import clsx from 'clsx';

export const Textarea: React.FC<TextareaHTMLAttributes<HTMLTextAreaElement>> = ({ className, ...props }) => (
  <textarea
    className={clsx(
      'w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500',
      className,
    )}
    {...props}
  />
);
