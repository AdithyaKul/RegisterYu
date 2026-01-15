'use server';

import { getServiceSupabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function getEvents() {
    const supabase = getServiceSupabase();

    // Fetch events with registration count
    // Note: Supabase JS select with count on foreign key requires careful syntax or separate queries if using service role strongly typed
    // We can use the same syntax as client if relationships are defined
    const { data, error } = await supabase
        .from('events')
        .select('*, registrations(count)')
        .order('date', { ascending: true });

    if (error) {
        console.error('Error fetching events:', error);
        throw new Error(error.message);
    }

    // Map to clean structure
    return data.map((e: any) => ({
        ...e,
        title: e.title || e.name || 'Untitled',
        date: e.date || e.event_date || new Date().toISOString(),
        registrations_count: e.registrations && e.registrations[0] ? e.registrations[0].count : 0
    }));
}

export async function getEvent(id: string) {
    const supabase = getServiceSupabase();

    const { data, error } = await supabase
        .from('events')
        .select('*')
        .eq('id', id)
        .single();

    if (error) return null;

    return {
        ...data,
        title: data.title || data.name,
        date: data.date || data.event_date
    };
}

export async function getEventStats(id: string) {
    const supabase = getServiceSupabase();

    // Registrations with checked_in status
    const { data: regs, error } = await supabase
        .from('registrations')
        .select('status, ticket_code')
        .eq('event_id', id);

    if (error || !regs) return { registrations: 0, revenue: 0, attendees: 0 };

    const checkedIn = regs.filter((r: any) => r.status === 'checked_in').length;
    // Fetch price to calc revenue
    const { data: event } = await supabase.from('events').select('price_amount').eq('id', id).single();
    const revenue = (event?.price_amount || 0) * regs.length;

    return {
        registrations: regs.length,
        attendees: checkedIn,
        revenue
    };
}

export async function getEventRegistrations(id: string) {
    const supabase = getServiceSupabase();
    const { data, error } = await supabase
        .from('registrations')
        .select('*, profiles(full_name, email, phone)')
        .eq('event_id', id)
        .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
}

export async function getEventAssignments(id: string) {
    const supabase = getServiceSupabase();
    const { data, error } = await supabase
        .from('event_assignments')
        .select('id, user_id, role, profiles(full_name, email, role)')
        .eq('event_id', id);

    if (error) throw new Error(error.message);
    return data;
}

export async function createEvent(formData: any) {
    const supabase = getServiceSupabase();

    // Ensure date is ISO
    const payload = {
        title: formData.title,
        description: formData.description,
        date: new Date(formData.date).toISOString(),
        location: formData.location,
        category: formData.category,
        capacity: Number(formData.capacity),
        price_amount: Number(formData.price_amount),
        image_url: formData.image_url,
        status: formData.status || 'draft'
    };

    const { data, error } = await supabase.from('events').insert([payload]).select().single();

    if (error) throw new Error(error.message);
    revalidatePath('/dashboard/events');
    return data;
}

export async function updateEvent(id: string, formData: any) {
    const supabase = getServiceSupabase();

    const payload: any = { ...formData };
    if (payload.date) payload.date = new Date(payload.date).toISOString();

    // Remove ID from payload if present to avoid error
    delete payload.id;

    const { error } = await supabase.from('events').update(payload).eq('id', id);
    if (error) throw new Error(error.message);

    revalidatePath(`/dashboard/events/${id}`);
    revalidatePath('/dashboard/events');
    return { success: true };
}

export async function deleteEvent(id: string) {
    const supabase = getServiceSupabase();
    const { error } = await supabase.from('events').delete().eq('id', id);
    if (error) throw new Error(error.message);
    revalidatePath('/dashboard/events');
    return { success: true };
}

export async function addEventAssignment(eventId: string, userId: string, role: string) {
    const supabase = getServiceSupabase();
    const { error } = await supabase
        .from('event_assignments')
        .insert([{ event_id: eventId, user_id: userId, role }]);

    if (error) throw new Error(error.message);
    revalidatePath(`/dashboard/events/${eventId}`);
    return { success: true };
}

export async function removeEventAssignment(assignmentId: string, eventId: string) {
    const supabase = getServiceSupabase();
    const { error } = await supabase
        .from('event_assignments')
        .delete()
        .eq('id', assignmentId);

    if (error) throw new Error(error.message);
    revalidatePath(`/dashboard/events/${eventId}`);
    return { success: true };
}

export async function searchUsers(query: string) {
    const supabase = getServiceSupabase();
    const { data } = await supabase
        .from('profiles')
        .select('id, full_name, email')
        .ilike('email', `%${query}%`)
        .limit(5);
    return data || [];
}
