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

    // 1. Log the event (requires service role key to bypass RLS, or anon insert policy)
    const { data: eventData, error: eventError } = await supabase
      .from('device_events')
      .insert([
        {
          device_id,
          event_type,
          payload: metadata || {}
        }
      ])
      .select()
      .maybeSingle();

    if (eventError) {
      console.warn('Notice: device_events insert skipped (requires service_role key):', eventError.message);
    }

    // 2. If this is an SOS Trigger, auto-generate an incident
    if (event_type === 'SOS_TRIGGERED') {
      // Look up device and campus block location
      const { data: device } = await supabase
        .from('devices')
        .select('campus_block, campus_block_id, campus_blocks(latitude, longitude)')
        .eq('device_id', device_id)
        .maybeSingle();

      const campusBlockName = device?.campus_block || 'Engineering Block';
      const blockData = device?.campus_blocks as any;

      await supabase.from('incidents').insert([{
        type: 'security',
        priority: 1,
        source: 'iot',
        latitude: blockData?.latitude || 3.1390,
        longitude: blockData?.longitude || 101.6869,
        campus_block: campusBlockName,
        location_description: `IoT Station: ${device_id}`,
        description: `Emergency SOS triggered from Hardware Station ${device_id}`,
        status: 'created'
      }]);
    }

    return NextResponse.json({ success: true, event: eventData }, { status: 201 });
  } catch (error: any) {
    console.error('IoT Webhook Error:', error.message);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
