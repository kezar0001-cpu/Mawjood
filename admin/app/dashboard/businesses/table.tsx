'use client';

import { useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { createSupabaseBrowserClient } from '@/lib/supabaseClient';
import { Input } from '@/components/ui/Input';
import { Select } from '@/components/ui/Select';
import { Table, THead, TR, TH, TBody, TD } from '@/components/ui/Table';
import { Database } from '@/types/supabase';

const PAGE_SIZE = 20;

type BusinessRow = Database['public']['Tables']['businesses']['Row'] & {
  category?: { name_ar: string } | null;
};

type Props = {
  categories: { id: string; name_ar: string }[];
};

export default function BusinessesTable({ categories }: Props) {
  const supabase = createSupabaseBrowserClient();
  const router = useRouter();
  const searchParams = useSearchParams();

  const [data, setData] = useState<BusinessRow[]>([]);
  const [count, setCount] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [page, setPage] = useState(1);
  const [cityFilter, setCityFilter] = useState(searchParams.get('city') || '');
  const [categoryFilter, setCategoryFilter] = useState(searchParams.get('category') || '');
  const [search, setSearch] = useState(searchParams.get('search') || '');

  const loadBusinesses = async () => {
    setLoading(true);
    let query = supabase
      .from('businesses')
      .select('id, name, city, phone, rating, category:categories(name_ar)', { count: 'exact' })
      .order('name');

    if (cityFilter) {
      query = query.ilike('city', `%${cityFilter}%`);
    }
    if (categoryFilter) {
      query = query.eq('category_id', categoryFilter);
    }
    if (search) {
      query = query.ilike('name', `%${search}%`);
    }

    const from = (page - 1) * PAGE_SIZE;
    const to = from + PAGE_SIZE - 1;

    const { data, error, count } = await query.range(from, to);

    if (error) {
      setError(error.message);
      setData([]);
    } else {
      setData((data || []) as BusinessRow[]);
      setCount(count ?? null);
    }

    setLoading(false);
  };

  useEffect(() => {
    void loadBusinesses();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, cityFilter, categoryFilter, search]);

  const totalPages = useMemo(() => (count ? Math.ceil(count / PAGE_SIZE) : 1), [count]);

  return (
    <div className="space-y-4">
      <div className="grid gap-3 md:grid-cols-4">
        <Input placeholder="Filter by city" value={cityFilter} onChange={(e) => setCityFilter(e.target.value)} />
        <Select value={categoryFilter} onChange={(e) => setCategoryFilter(e.target.value)}>
          <option value="">All categories</option>
          {categories.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {cat.name_ar}
            </option>
          ))}
        </Select>
        <Input
          placeholder="Search by name"
          className="md:col-span-2"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
      {loading ? (
        <p>Loading...</p>
      ) : (
        <Table>
          <THead>
            <TR>
              <TH>Name</TH>
              <TH>City</TH>
              <TH>Category</TH>
              <TH>Rating</TH>
              <TH>Phone</TH>
            </TR>
          </THead>
          <TBody>
            {data.map((business) => (
              <TR
                key={business.id}
                className="cursor-pointer hover:bg-gray-50"
                onClick={() => router.push(`/dashboard/businesses/${business.id}`)}
              >
                <TD>{business.name}</TD>
                <TD>{business.city || '-'}</TD>
                <TD>{business.category?.name_ar || '-'}</TD>
                <TD>{business.rating ?? '-'}</TD>
                <TD>{business.phone || '-'}</TD>
              </TR>
            ))}
            {data.length === 0 && (
              <TR>
                <TD colSpan={5}>No businesses found.</TD>
              </TR>
            )}
          </TBody>
        </Table>
      )}

      <div className="flex items-center justify-between text-sm">
        <span>
          Page {page} of {totalPages}
        </span>
        <div className="space-x-2">
          <button
            disabled={page === 1}
            className="rounded border border-gray-200 px-3 py-1 disabled:cursor-not-allowed disabled:opacity-50"
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            Previous
          </button>
          <button
            disabled={page === totalPages}
            className="rounded border border-gray-200 px-3 py-1 disabled:cursor-not-allowed disabled:opacity-50"
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
}
