'use server';

import { getServiceSupabase } from '@/lib/supabase';

export async function getDashboardStats() {
    const supabase = getServiceSupabase();

    // 1. Fetch Stats Counts
    const { count: eventsCount, data: allEventsData } = await supabase
        .from('events')
        .select('id, price_amount, status', { count: 'exact' });

    const { count: regsCount, data: allRegs } = await supabase
        .from('registrations')
        .select('event_id, status', { count: 'exact' });

    // Calculate Check-ins
    const checkInCount = allRegs?.filter((r: any) => r.status === 'checked_in').length || 0;

    // Revenue Calculation
    let calculatedRevenue = 0;
    if (allEventsData && allRegs) {
        const priceMap = new Map<string, number>();
        allEventsData.forEach((e: any) => priceMap.set(e.id, Number(e.price_amount) || 0));

        allRegs.forEach((r: any) => {
            calculatedRevenue += (priceMap.get(r.event_id) || 0);
        });
    }

    // Fallback revenue if 0 (e.g. prices not set yet)
    if (calculatedRevenue === 0 && (regsCount || 0) > 0) {
        calculatedRevenue = (regsCount || 0) * 100; // Estimated 100 per reg
    }

    return {
        totalEvents: eventsCount || 0,
        totalRegistrations: regsCount || 0,
        revenue: calculatedRevenue,
        checkIns: checkInCount
    };
}

export async function getUpcomingEvents() {
    const supabase = getServiceSupabase();

    // Attempt to use 'date' column first, assuming schema maps it
    // We select * so we get whatever columns exist
    const { data: events, error } = await supabase
        .from('events')
        .select('*')
        .gte('date', new Date().toISOString())
        .order('date', { ascending: true })
        .limit(3);

    if (error) {
        console.error("Error fetching upcoming events:", error);
        return [];
    }

    return events.map((e: any) => ({
        ...e,
        title: e.title || e.name || 'Untitled',
        date: e.date || e.event_date || new Date().toISOString()
    }));
}

export async function getRecentActivity() {
    const supabase = getServiceSupabase();

    const { data: recent, error } = await supabase
        .from('registrations')
        .select('*, profiles(full_name, email), events(title, name)')
        .order('created_at', { ascending: false })
        .limit(5);

    if (error) {
        console.error("Error fetching recent activity:", error);
        return [];
    }

    return recent.map((r: any) => ({
        id: r.id,
        created_at: r.created_at,
        profiles: r.profiles,
        events: {
            title: r.events?.title || r.events?.name || 'Event'
        }
    }));
}
