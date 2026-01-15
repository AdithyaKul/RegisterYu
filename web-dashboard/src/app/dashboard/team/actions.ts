'use server';

import { getServiceSupabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function getTeamMembers() {
    const supabase = getServiceSupabase();

    // Fetch all profiles using service role (bypasses RLS)
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error fetching team members:', error);
        throw new Error(error.message);
    }

    return data || [];
}

export async function updateTeamMemberRole(userId: string, newRole: string) {
    const supabase = getServiceSupabase();

    const { error } = await supabase
        .from('profiles')
        .update({ role: newRole })
        .eq('id', userId);

    if (error) {
        console.error('Error updating role:', error);
        throw new Error(error.message);
    }

    revalidatePath('/dashboard/team');
    return { success: true };
}
