import { Card } from '@/components/ui/Card';
import { createSupabaseServerClient } from '@/lib/supabaseServer';

export const dynamic = 'force-dynamic';

export default async function DashboardPage() {
  const supabase = createSupabaseServerClient();

  const [{ count: businessCount }, { count: categoryCount }, { data: citiesData }] = await Promise.all([
    supabase.from('businesses').select('*', { count: 'exact', head: true }),
    supabase.from('categories').select('*', { count: 'exact', head: true }),
    supabase.from('businesses').select('city'),
  ]);

  const cityCounts = (citiesData || []).reduce<Record<string, number>>((acc, row) => {
    const city = row.city || 'Unknown';
    acc[city] = (acc[city] || 0) + 1;
    return acc;
  }, {});

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card title="Total Businesses">
          <p className="text-3xl font-bold">{businessCount ?? 0}</p>
        </Card>
        <Card title="Total Categories">
          <p className="text-3xl font-bold">{categoryCount ?? 0}</p>
        </Card>
        <Card title="Cities Tracked">
          <p className="text-3xl font-bold">{Object.keys(cityCounts).length}</p>
        </Card>
      </div>

      <Card title="Businesses by City">
        <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
          {Object.entries(cityCounts).map(([city, count]) => (
            <div key={city} className="rounded-md border border-gray-200 bg-gray-50 p-3 text-sm">
              <div className="font-semibold text-gray-800">{city}</div>
              <div className="text-gray-600">{count} businesses</div>
            </div>
          ))}
          {Object.keys(cityCounts).length === 0 && <p className="text-gray-600">No data available.</p>}
        </div>
      </Card>
    </div>
  );
}
