'use server';

import { getServiceSupabase } from '@/lib/supabase';

export async function getRevenueStats() {
    const supabase = getServiceSupabase();

    // Fetch all registrations with event details (price)
    // We need to calculate manually since we don't have a payments table
    const { data: regs, error } = await supabase
        .from('registrations')
        .select(`
            id,
            status,
            created_at,
            events (id, price_amount)
        `);

    if (error) {
        console.error("Error fetching revenue stats:", error);
        return { total: 0, thisMonth: 0, pending: 0, refunded: 0, growth: 0 };
    }

    let total = 0;
    let thisMonth = 0;
    let pending = 0;
    let refunded = 0;
    let lastMonth = 0;

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    const prevMonthDate = new Date();
    prevMonthDate.setMonth(now.getMonth() - 1);
    const prevMonth = prevMonthDate.getMonth();
    const prevMonthYear = prevMonthDate.getFullYear();

    regs.forEach((r: any) => {
        const price = r.events?.price_amount || 0;
        const date = new Date(r.created_at);

        if (r.status === 'confirmed' || r.status === 'checked_in') {
            total += price;

            if (date.getMonth() === currentMonth && date.getFullYear() === currentYear) {
                thisMonth += price;
            }
            if (date.getMonth() === prevMonth && date.getFullYear() === prevMonthYear) {
                lastMonth += price;
            }
        } else if (r.status === 'pending') {
            pending += price;
        } else if (r.status === 'cancelled') {
            refunded += price; // Assuming cancelled means refunded for analytics
        }
    });

    const growth = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth) * 100 : 0;

    return {
        total,
        thisMonth,
        pending,
        refunded,
        growth: Number(growth.toFixed(1))
    };
}

export async function getRevenueByEvent() {
    const supabase = getServiceSupabase();

    const { data: events, error } = await supabase
        .from('events')
        .select('id, title, name, price_amount, registrations(count)');

    if (error) return [];

    return events.map((e: any) => ({
        event: e.title || e.name || 'Untitled',
        revenue: (e.price_amount || 0) * (e.registrations?.[0]?.count || 0),
        registrations: e.registrations?.[0]?.count || 0,
        color: '#' + Math.floor(Math.random() * 16777215).toString(16) // Random color for chart
    })).sort((a: any, b: any) => b.revenue - a.revenue);
}

export async function getRecentTransactions() {
    const supabase = getServiceSupabase();

    const { data: regs, error } = await supabase
        .from('registrations')
        .select(`
            id,
            status,
            created_at,
            profiles (full_name),
            events (title, name, price_amount)
        `)
        .order('created_at', { ascending: false })
        .limit(10);

    if (error) return [];

    return regs.map((r: any) => ({
        id: r.id.substring(0, 8).toUpperCase(),
        name: r.profiles?.full_name || 'Guest',
        event: r.events?.title || r.events?.name || 'Event',
        amount: r.events?.price_amount || 0,
        status: r.status === 'checked_in' ? 'completed' : r.status,
        date: r.created_at,
        method: 'UPI' // Default assumption
    }));
}
