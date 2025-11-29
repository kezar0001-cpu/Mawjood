import { notFound } from 'next/navigation';
import { BusinessForm } from '@/components/businesses/BusinessForm';
import { createSupabaseServerClient } from '@/lib/supabaseServer';

export default async function EditBusinessPage({ params }: { params: { id: string } }) {
  const supabase = createSupabaseServerClient();
  const [{ data: business }, { data: categories }] = await Promise.all([
    supabase.from('businesses').select('*').eq('id', params.id).single(),
    supabase.from('categories').select('*').order('name_ar'),
  ]);

  if (!business) {
    notFound();
  }

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Edit Business</h1>
      <BusinessForm business={business} categories={categories || []} />
    </div>
  );
}
