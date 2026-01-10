
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://cchvvapkchrqqleznxvr.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjaHZ2YXBrY2hycXFsZXpueHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4ODQ3MzgsImV4cCI6MjA4MzQ2MDczOH0.kirmDxY_01dx_qMTi25quoHt4l5-J8HfaWF8CZ0OpLQ';

const supabase = createClient(supabaseUrl, supabaseKey);

async function signUp() {
    console.log("Attempting sign in...");
    const { data, error } = await supabase.auth.signInWithPassword({
        email: 'admin@sambhram.com',
        password: 'password',
    });

    if (error) {
        console.error("Error signing in:", error);
    } else {
        console.log("Sign in successful.");
        console.log("User:", data.user?.email);
        console.log("Session:", !!data.session);
    }
}

signUp();
