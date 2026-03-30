-- SUPABASE REALTIME FIX - Remove View from Publication
-- Run in Supabase SQL Editor

-- 1. Remove dashboard_stats view from realtime publication (views not supported)
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS public.dashboard_stats;

-- 2. Enable realtime for actual tables only
ALTER PUBLICATION supabase_realtime ADD TABLE public.admins, public.products, public.announcements;

-- 3. Verify
SELECT * FROM supabase_realtime.publications;

-- SUCCESS! Realtime updates for tables only (views unsupported)
-- Frontend will refresh data via API calls (no realtime needed for dashboard)

-- Optional: Drop view if not needed (query directly)
DROP VIEW IF EXISTS dashboard_stats;

-- Test API calls work → realtime via Supabase dashboard UI

