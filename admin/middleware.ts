import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs';
import { Database } from './types/supabase';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient<Database>({ req, res });

  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    const {
      data: { session },
    } = await supabase.auth.getSession();

    if (!session?.user) {
      const redirectUrl = new URL('/login', req.url);
      redirectUrl.searchParams.set('redirectedFrom', req.nextUrl.pathname);
      return NextResponse.redirect(redirectUrl);
    }

    const { data: adminRecord } = await supabase
      .from('admins')
      .select('id')
      .eq('user_id', session.user.id)
      .single();

    if (!adminRecord) {
      await supabase.auth.signOut();
      const redirectUrl = new URL('/login', req.url);
      redirectUrl.searchParams.set('error', 'access_denied');
      return NextResponse.redirect(redirectUrl);
    }
  }

  return res;
}

export const config = {
  matcher: ['/dashboard/:path*'],
};
