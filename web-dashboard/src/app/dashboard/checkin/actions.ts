'use server';

import { getServiceSupabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function getCheckinStats() {
    const supabase = getServiceSupabase();

    // Fetch total checkins
    const { count: checkedInCount } = await supabase
        .from('registrations')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'checked_in');

    // Fetch pending
    const { count: pendingCount } = await supabase
        .from('registrations')
        .select('*', { count: 'exact', head: true })
        .neq('status', 'checked_in');

    // Estimate last hour using check_in_time
    const oneHourAgo = new Date(Date.now() - 3600000).toISOString();
    const { count: lastHourCount } = await supabase
        .from('registrations')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'checked_in')
        .gte('check_in_time', oneHourAgo);

    // Fetch recent checkins
    const { data: recent } = await supabase
        .from('registrations')
        .select('id, ticket_code, check_in_time, status, profiles(full_name), events(title, name)')
        .eq('status', 'checked_in')
        .order('check_in_time', { ascending: false })
        .limit(10);

    return {
        totalCheckins: checkedInCount || 0,
        pending: pendingCount || 0,
        lastHour: lastHourCount || 0,
        recent: recent?.map((r: any) => ({
            id: r.id,
            name: r.profiles?.full_name || 'Guest',
            event: r.events?.title || r.events?.name || 'Event',
            ticketId: r.ticket_code || r.id.substring(0, 8).toUpperCase(),
            time: r.check_in_time ? new Date(r.check_in_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Unknown',
            success: true
        })) || []
    };
}

export async function performCheckIn(ticketCode: string) {
    const supabase = getServiceSupabase();

    // Find by ticket_code
    const { data: ticket, error } = await supabase
        .from('registrations')
        .select('*, profiles(full_name), events(title, name)')
        .eq('ticket_code', ticketCode)
        .single();

    if (error || !ticket) {
        throw new Error('Ticket not found');
    }

    if (ticket.status === 'checked_in') {
        // Return existing info but indicate failure/already checked in
        return {
            success: false,
            message: 'Already checked in',
            record: {
                id: ticket.id,
                name: ticket.profiles?.full_name || 'Guest',
                event: ticket.events?.title || ticket.events?.name || 'Event',
                ticketId: ticket.ticket_code,
                time: new Date().toLocaleTimeString(),
                success: false
            }
        };
    }

    // Perform Check In
    const { error: updateError } = await supabase
        .from('registrations')
        .update({ status: 'checked_in', check_in_time: new Date().toISOString() })
        .eq('id', ticket.id);

    if (updateError) throw new Error(updateError.message);

    revalidatePath('/dashboard/checkin');

    return {
        success: true,
        message: 'Check-in Successful',
        record: {
            id: ticket.id,
            name: ticket.profiles?.full_name || 'Guest',
            event: ticket.events?.title || ticket.events?.name || 'Event',
            ticketId: ticket.ticket_code,
            time: new Date().toLocaleTimeString(),
            success: true
        }
    };
}
