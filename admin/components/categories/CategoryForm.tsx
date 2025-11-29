'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createSupabaseBrowserClient } from '@/lib/supabaseClient';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { Database } from '../../types/supabase';

type Category = Database['public']['Tables']['categories']['Row'];

type Props = {
  category?: Category;
};

export const CategoryForm = ({ category }: Props) => {
  const supabase = createSupabaseBrowserClient();
  const router = useRouter();
  const [nameAr, setNameAr] = useState(category?.name_ar ?? '');
  const [nameEn, setNameEn] = useState(category?.name_en ?? '');
  const [icon, setIcon] = useState(category?.icon ?? '');
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setStatus(null);

    if (category) {
      const { error } = await supabase
        .from('categories')
        .update({ name_ar: nameAr, name_en: nameEn || null, icon: icon || null })
        .eq('id', category.id);
      if (error) {
        setStatus(error.message);
        setLoading(false);
        return;
      }
      setStatus('Category updated successfully.');
    } else {
      const { error } = await supabase
        .from('categories')
        .insert({ name_ar: nameAr, name_en: nameEn || null, icon: icon || null });
      if (error) {
        setStatus(error.message);
        setLoading(false);
        return;
      }
      setStatus('Category created successfully.');
    }

    setLoading(false);
    router.push('/dashboard/categories');
    router.refresh();
  };

  return (
    <form className="space-y-4" onSubmit={handleSubmit}>
      <div>
        <label className="mb-1 block text-sm font-medium text-gray-700">Name (Arabic) *</label>
        <Input value={nameAr} required onChange={(e) => setNameAr(e.target.value)} placeholder="الاسم بالعربية" />
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium text-gray-700">Name (English)</label>
        <Input value={nameEn ?? ''} onChange={(e) => setNameEn(e.target.value)} placeholder="English name" />
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium text-gray-700">Icon</label>
        <Input value={icon ?? ''} onChange={(e) => setIcon(e.target.value)} placeholder="e.g. sparkles" />
      </div>
      {status && <p className="text-sm text-green-600">{status}</p>}
      <div className="flex gap-3">
        <Button type="submit" disabled={loading}>
          {category ? 'Update Category' : 'Create Category'}
        </Button>
        <Button variant="secondary" type="button" onClick={() => router.back()}>
          Cancel
        </Button>
      </div>
    </form>
  );
};
