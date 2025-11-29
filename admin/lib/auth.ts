import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from './supabaseServer';

export const requireAdmin = async () => {
  const supabase = createSupabaseServerClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session?.user) {
    redirect('/login');
  }

  const { data: adminRecord, error } = await supabase
    .from('admins')
    .select('id, email')
    .eq('user_id', session.user.id)
    .single();

  if (error || !adminRecord) {
    await supabase.auth.signOut();
    redirect('/login?error=access_denied');
  }

  return { session, admin: adminRecord };
};
