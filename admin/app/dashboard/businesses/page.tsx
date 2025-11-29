import { Suspense } from 'react';
import { createSupabaseServerClient } from '@/lib/supabaseServer';
import BusinessesTable from './table';

export default async function BusinessesPage() {
  const supabase = createSupabaseServerClient();
  const { data: categories } = await supabase.from('categories').select('id, name_ar').order('name_ar');

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Businesses</h1>
        <a
          href="/dashboard/businesses/new"
          className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
        >
          New Business
        </a>
      </div>
      <Suspense fallback={<p>Loading businesses...</p>}>
        <BusinessesTable categories={categories || []} />
      </Suspense>
    </div>
  );
}
