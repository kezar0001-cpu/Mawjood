import { cookies } from 'next/headers';
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs';
import { Database } from '../types/supabase';

export const createSupabaseServerClient = () =>
  createServerComponentClient<Database>({ cookies });

export const createSupabaseServerClientFromCookies = (cookieStore: ReturnType<typeof cookies>) =>
  createServerComponentClient<Database>(
    { cookies: () => cookieStore },
  );
