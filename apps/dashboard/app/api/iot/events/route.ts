import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Setup Supabase client for backend (ideally with Service Role to bypass RLS for IoT)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'placeholder_key';
const supabase = createClient(supabaseUrl, supabaseKey);

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    // Basic verification for IoT hardware
    if (authHeader !== `Bearer ${process.env.IOT_API_KEY || 'campus_safe_iot_secret'}`) {
      return NextResponse.json({ error: 'Unauthorized hardware' }, { status: 401 });
    }

    const payload = await request.json();
    const { device_id, event_type, metadata } = payload;

    if (!device_id || !event_type) {
      return NextResponse.json({ error: 'device_id and event_type required' }, { status: 400 });
    }

    // 1. Log the event
    const { data: eventData, error: eventError } = await supabase
      .from('device_events')
      .insert([
        {
          device_id,
          event_type,
          metadata: metadata || {}
        }
      ])
      .select()
      .single();

    if (eventError) {
      return NextResponse.json({ error: eventError.message }, { status: 500 });
    }

    // 2. If this is an SOS Trigger, auto-generate an incident
    if (event_type === 'SOS_TRIGGERED') {
      // Look up device location
      const { data: device } = await supabase
        .from('devices')
        .select('latitude, longitude, campus_block')
        .eq('device_id', device_id)
        .single();

      if (device) {
        await supabase.from('incidents').insert([{
          type: 'security',
          priority: 1,
          source: 'iot',
          latitude: device.latitude,
          longitude: device.longitude,
          campus_block: device.campus_block,
          description: `Emergency SOS triggered from Hardware Station ${device_id}`,
          status: 'created'
        }]);
      }
    }

    return NextResponse.json({ success: true, event: eventData }, { status: 201 });
  } catch (error: any) {
    console.error('IoT Webhook Error:', error.message);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
