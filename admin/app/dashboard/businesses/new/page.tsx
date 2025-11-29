import { BusinessForm } from '@/components/businesses/BusinessForm';
import { createSupabaseServerClient } from '@/lib/supabaseServer';

export default async function NewBusinessPage() {
  const supabase = createSupabaseServerClient();
  const { data: categories } = await supabase.from('categories').select('*').order('name_ar');

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Create Business</h1>
      <BusinessForm categories={categories || []} />
    </div>
  );
}
