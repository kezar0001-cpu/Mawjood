import { notFound } from 'next/navigation';
import { CategoryForm } from '@/components/categories/CategoryForm';
import { createSupabaseServerClient } from '@/lib/supabaseServer';

export default async function EditCategoryPage({ params }: { params: { id: string } }) {
  const supabase = createSupabaseServerClient();
  const { data, error } = await supabase.from('categories').select('*').eq('id', params.id).single();

  if (error || !data) {
    notFound();
  }

  return (
    <div className="max-w-xl space-y-4">
      <h1 className="text-xl font-semibold">Edit Category</h1>
      <CategoryForm category={data} />
    </div>
  );
}
