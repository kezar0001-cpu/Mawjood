'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createSupabaseBrowserClient } from '@/lib/supabaseClient';
import { Input } from '@/components/ui/Input';
import { Select } from '@/components/ui/Select';
import { Textarea } from '@/components/ui/Textarea';
import { Button } from '@/components/ui/Button';
import { Database } from '@/types/supabase';

type Category = Database['public']['Tables']['categories']['Row'];
type Business = Database['public']['Tables']['businesses']['Row'];

type Props = {
  categories: Category[];
  business?: Business & { categories?: { name_ar: string } | null };
};

export const BusinessForm = ({ categories, business }: Props) => {
  const supabase = createSupabaseBrowserClient();
  const router = useRouter();

  const [name, setName] = useState(business?.name ?? '');
  const [categoryId, setCategoryId] = useState(business?.category_id ?? '');
  const [description, setDescription] = useState(business?.description ?? '');
  const [city, setCity] = useState(business?.city ?? '');
  const [address, setAddress] = useState(business?.address ?? '');
  const [phone, setPhone] = useState(business?.phone ?? '');
  const [rating, setRating] = useState<number | ''>(business?.rating ?? '');
  const [latitude, setLatitude] = useState<string>(business?.latitude?.toString() ?? '');
  const [longitude, setLongitude] = useState<string>(business?.longitude?.toString() ?? '');
  const [features, setFeatures] = useState((business?.features || []).join(', '));
  const [images, setImages] = useState((business?.images || []).join(', '));
  const [message, setMessage] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    const payload = {
      name,
      category_id: categoryId || null,
      description: description || null,
      city: city || null,
      address: address || null,
      phone: phone || null,
      rating: rating === '' ? null : Number(rating),
      latitude: latitude ? Number(latitude) : null,
      longitude: longitude ? Number(longitude) : null,
      features: features ? features.split(',').map((f) => f.trim()).filter(Boolean) : null,
      images: images ? images.split(',').map((i) => i.trim()).filter(Boolean) : null,
    };

    if (business) {
      const { error } = await supabase.from('businesses').update(payload).eq('id', business.id);
      if (error) {
        setMessage(error.message);
        setLoading(false);
        return;
      }
      setMessage('Business updated.');
    } else {
      const { error } = await supabase.from('businesses').insert(payload);
      if (error) {
        setMessage(error.message);
        setLoading(false);
        return;
      }
      setMessage('Business created.');
    }

    setLoading(false);
    router.push('/dashboard/businesses');
    router.refresh();
  };

  return (
    <form className="space-y-4" onSubmit={handleSubmit}>
      <div className="grid gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Name *</label>
          <Input required value={name} onChange={(e) => setName(e.target.value)} placeholder="Business name" />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Category</label>
          <Select value={categoryId ?? ''} onChange={(e) => setCategoryId(e.target.value)}>
            <option value="">Select category</option>
            {categories.map((cat) => (
              <option key={cat.id} value={cat.id}>
                {cat.name_ar}
              </option>
            ))}
          </Select>
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">City</label>
          <Input value={city ?? ''} onChange={(e) => setCity(e.target.value)} placeholder="Baghdad" />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Address</label>
          <Input value={address ?? ''} onChange={(e) => setAddress(e.target.value)} placeholder="Street address" />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Phone</label>
          <Input value={phone ?? ''} onChange={(e) => setPhone(e.target.value)} placeholder="0770..." />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Rating</label>
          <Input
            type="number"
            min={0}
            max={5}
            step={0.1}
            value={rating}
            onChange={(e) => setRating(e.target.value === '' ? '' : Number(e.target.value))}
            placeholder="4.5"
          />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Latitude</label>
          <Input value={latitude} onChange={(e) => setLatitude(e.target.value)} placeholder="33.3128" />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Longitude</label>
          <Input value={longitude} onChange={(e) => setLongitude(e.target.value)} placeholder="44.3615" />
        </div>
      </div>

      <div>
        <label className="mb-1 block text-sm font-medium text-gray-700">Description</label>
        <Textarea
          rows={3}
          value={description ?? ''}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Description"
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Features (comma separated)</label>
          <Input value={features} onChange={(e) => setFeatures(e.target.value)} placeholder="wifi, parking" />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-gray-700">Image URLs (comma separated)</label>
          <Input value={images} onChange={(e) => setImages(e.target.value)} placeholder="https://..." />
        </div>
      </div>

      {message && <p className="text-sm text-green-700">{message}</p>}
      <div className="flex gap-3">
        <Button type="submit" disabled={loading}>
          {business ? 'Update Business' : 'Create Business'}
        </Button>
        <Button variant="secondary" type="button" onClick={() => router.back()}>
          Cancel
        </Button>
      </div>
    </form>
  );
};
