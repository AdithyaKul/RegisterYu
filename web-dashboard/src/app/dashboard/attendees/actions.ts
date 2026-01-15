'use server';

import { getServiceSupabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function getAttendees() {
    const supabase = getServiceSupabase();

    const { data, error } = await supabase
        .from('registrations')
        .select(`
            *,
            profiles:user_id (id, full_name, email, phone, college_id, department),
            events:event_id (id, title, name)
        `)
        .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);

    return data.map((reg: any) => ({
        id: reg.id,
        name: reg.profiles?.full_name || 'Guest',
        email: reg.profiles?.email,
        phone: reg.profiles?.phone,
        collegeId: reg.profiles?.college_id || 'N/A',
        department: reg.profiles?.department || 'N/A',
        event: reg.events?.title || reg.events?.name || 'Unknown Event',
        ticketId: reg.ticket_code,
        status: reg.status,
        registeredAt: reg.created_at,
        checkedInAt: reg.check_in_time,
        avatar: (reg.profiles?.full_name?.[0] || 'U').toUpperCase()
    }));
}

export async function updateAttendeeStatus(registrationId: string, status: string) {
    const supabase = getServiceSupabase();

    const updateData: any = { status };
    if (status === 'checked_in') {
        updateData.check_in_time = new Date().toISOString();
    } else if (status === 'confirmed') {
        updateData.check_in_time = null; // Reset if moving back
    }

    const { error } = await supabase
        .from('registrations')
        .update(updateData)
        .eq('id', registrationId);

    if (error) throw new Error(error.message);
    revalidatePath('/dashboard/attendees');
}
