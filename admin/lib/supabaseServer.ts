import { cookies } from 'next/headers';
import { createServerComponentClient, createServerClient } from '@supabase/auth-helpers-nextjs';
import { Database } from '@/types/supabase';

export const createSupabaseServerClient = () =>
  createServerComponentClient<Database>({ cookies });

export const createSupabaseServerClientFromCookies = (cookieStore: ReturnType<typeof cookies>) =>
  createServerClient<Database>(
    {
      supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL!,
      supabaseKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    },
    { cookies: () => cookieStore },
  );
