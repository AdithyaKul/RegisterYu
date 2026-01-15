'use server';

import { getServiceSupabase } from '@/lib/supabase';

export async function getNotificationEvents() {
    const supabase = getServiceSupabase();
    const { data, error } = await supabase
        .from('events')
        .select('id, name, title'); // select title too as name might not be populated in old records

    if (error) {
        console.error("Error fetching notification events:", error);
        return [];
    }

    return data.map((e: any) => ({
        id: e.id,
        name: e.title || e.name || 'Untitled Event'
    }));
}

export async function getNotificationAttendeeCount(eventId?: string) {
    const supabase = getServiceSupabase();

    let query = supabase.from('registrations').select('*', { count: 'exact', head: true });

    if (eventId) {
        query = query.eq('event_id', eventId);
    }

    const { count, error } = await query;

    if (error) {
        console.error("Error fetching notification count:", error);
        return 0;
    }

    return count || 0;
}
