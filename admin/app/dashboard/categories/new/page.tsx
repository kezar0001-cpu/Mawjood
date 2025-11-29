import { CategoryForm } from '@/components/categories/CategoryForm';

export default function NewCategoryPage() {
  return (
    <div className="max-w-xl space-y-4">
      <h1 className="text-xl font-semibold">Create Category</h1>
      <CategoryForm />
    </div>
  );
}
