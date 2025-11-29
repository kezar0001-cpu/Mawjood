'use client';

import { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import { createSupabaseBrowserClient } from '@/lib/supabaseClient';
import { Table, THead, TR, TH, TBody, TD } from '@/components/ui/Table';
import { Button } from '@/components/ui/Button';
import { Database } from '@/types/supabase';

const pageSize = 50;

type Category = Database['public']['Tables']['categories']['Row'];

export default function CategoriesPage() {
  const supabase = createSupabaseBrowserClient();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadCategories = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase.from('categories').select('*').order('name_ar', { ascending: true }).limit(pageSize);
    if (error) {
      setError(error.message);
    } else {
      setCategories(data || []);
    }
    setLoading(false);
  }, [supabase]);

  useEffect(() => {
    void loadCategories();
  }, [loadCategories]);

  const handleDelete = async (id: string) => {
    const confirmed = confirm('Delete this category?');
    if (!confirmed) return;
    const { error } = await supabase.from('categories').delete().eq('id', id);
    if (error) {
      setError(error.message);
    } else {
      await loadCategories();
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Categories</h1>
        <Link href="/dashboard/categories/new">
          <Button>Create Category</Button>
        </Link>
      </div>
      {error && <p className="text-red-600">{error}</p>}
      {loading ? (
        <p>Loading...</p>
      ) : (
        <Table>
          <THead>
            <TR>
              <TH>Arabic Name</TH>
              <TH>English Name</TH>
              <TH>Icon</TH>
              <TH>Actions</TH>
            </TR>
          </THead>
          <TBody>
            {categories.map((category) => (
              <TR key={category.id}>
                <TD>{category.name_ar}</TD>
                <TD>{category.name_en || '-'}</TD>
                <TD>{category.icon || '-'}</TD>
                <TD className="space-x-2">
                  <Link href={`/dashboard/categories/${category.id}`} className="text-blue-600 hover:underline">
                    Edit
                  </Link>
                  <button className="text-red-600 hover:underline" onClick={() => handleDelete(category.id)}>
                    Delete
                  </button>
                </TD>
              </TR>
            ))}
            {categories.length === 0 && (
              <TR>
                <TD colSpan={4}>No categories found.</TD>
              </TR>
            )}
          </TBody>
        </Table>
      )}
    </div>
  );
}
