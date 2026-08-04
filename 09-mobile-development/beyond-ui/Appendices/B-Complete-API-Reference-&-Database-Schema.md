# Appendix B: Complete API Reference & Database Schema

## Comprehensive Reference for Backend APIs and Data Models

This appendix provides a complete reference for all API endpoints, database schemas, and data models used throughout the NexusCollect application. Use this as a developer reference when building new features or troubleshooting integration issues.

---

## B.1 Supabase Database Schema

### B.1.1 Complete Schema Definition

```sql
-- Complete Supabase Database Schema for NexusCollect

-- =====================================================
-- EXTENSIONS
-- =====================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Enable JSON operations
CREATE EXTENSION IF NOT EXISTS "jsonb_ops";

-- =====================================================
-- TABLES
-- =====================================================

-- 1. Users (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    phone_number TEXT,
    company TEXT,
    job_title TEXT,
    bio TEXT,
    website TEXT,
    social_links JSONB DEFAULT '{}'::jsonb,
    preferences JSONB DEFAULT '{"theme": "system", "notifications": true}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT profiles_email_unique UNIQUE (email),
    CONSTRAINT profiles_phone_unique UNIQUE (phone_number)
);

-- 2. User Sessions
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_id TEXT NOT NULL,
    device_name TEXT,
    device_type TEXT,
    ip_address TEXT,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    CONSTRAINT user_sessions_token_unique UNIQUE (token),
    CONSTRAINT user_sessions_device_unique UNIQUE (user_id, device_id)
);

-- 3. Forms
CREATE TABLE IF NOT EXISTS public.forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    fields JSONB NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    is_public BOOLEAN DEFAULT FALSE,
    is_template BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1,
    category TEXT,
    tags TEXT[],
    settings JSONB DEFAULT '{"allow_editing": true, "allow_photos": true, "allow_location": true}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    published_at TIMESTAMP WITH TIME ZONE,
    archived_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    CONSTRAINT forms_title_check CHECK (char_length(title) > 0),
    CONSTRAINT forms_fields_check CHECK (jsonb_array_length(fields) > 0)
);

-- 4. Collections (Entries)
CREATE TABLE IF NOT EXISTS public.collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id UUID REFERENCES public.forms(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    data JSONB NOT NULL,
    location JSONB,
    photos TEXT[],
    videos TEXT[],
    audio TEXT[],
    signature JSONB,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'synced', 'archived', 'rejected')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    tags TEXT[],
    notes TEXT,
    synced_at TIMESTAMP WITH TIME ZONE,
    submitted_at TIMESTAMP WITH TIME ZONE,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    CONSTRAINT collections_status_check CHECK (status IN ('draft', 'submitted', 'synced', 'archived', 'rejected'))
);

-- 5. Sync Queue
CREATE TABLE IF NOT EXISTS public.sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    data JSONB NOT NULL,
    original_data JSONB,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 5,
    last_attempt TIMESTAMP WITH TIME ZONE,
    next_attempt TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    error_stack TEXT,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT sync_queue_operation_check CHECK (operation IN ('create', 'update', 'delete')),
    CONSTRAINT sync_queue_status_check CHECK (status IN ('pending', 'processing', 'completed', 'failed'))
);

-- 6. Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('sync', 'mention', 'update', 'alert', 'reminder', 'info', 'error')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    link TEXT,
    image_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    is_actionable BOOLEAN DEFAULT FALSE,
    action_buttons JSONB,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high')),
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT notifications_type_check CHECK (type IN ('sync', 'mention', 'update', 'alert', 'reminder', 'info', 'error'))
);

-- 7. Teams
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    banner_url TEXT,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    settings JSONB DEFAULT '{"allow_public_forms": false, "require_approval": true}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT teams_slug_unique UNIQUE (slug),
    CONSTRAINT teams_name_check CHECK (char_length(name) > 0)
);

-- 8. Team Members
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'editor', 'viewer')),
    permissions JSONB DEFAULT '{}'::jsonb,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT team_members_unique UNIQUE (team_id, user_id),
    CONSTRAINT team_members_role_check CHECK (role IN ('owner', 'admin', 'editor', 'viewer'))
);

-- 9. Audit Logs
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    resource TEXT NOT NULL,
    resource_id UUID,
    changes JSONB,
    details JSONB,
    ip_address TEXT,
    user_agent TEXT,
    location JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 10. Analytics
CREATE TABLE IF NOT EXISTS public.analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_name TEXT NOT NULL,
    session_id TEXT,
    device_info JSONB,
    properties JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 11. Feedback & Ratings
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('bug', 'feature', 'feedback', 'rating')),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    screenshot_urls TEXT[],
    user_agent TEXT,
    platform TEXT,
    app_version TEXT,
    device_info JSONB,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'reviewed', 'in_progress', 'resolved', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT feedback_type_check CHECK (type IN ('bug', 'feature', 'feedback', 'rating'))
);

-- 12. Push Tokens
CREATE TABLE IF NOT EXISTS public.push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    token TEXT NOT NULL,
    device_type TEXT NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_used TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    CONSTRAINT push_tokens_token_unique UNIQUE (token)
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Profiles
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_full_name ON public.profiles(full_name);
CREATE INDEX idx_profiles_is_active ON public.profiles(is_active);
CREATE INDEX idx_profiles_company ON public.profiles(company);
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at DESC);

-- User Sessions
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON public.user_sessions(token);
CREATE INDEX idx_user_sessions_expires_at ON public.user_sessions(expires_at);

-- Forms
CREATE INDEX idx_forms_user_id ON public.forms(user_id);
CREATE INDEX idx_forms_team_id ON public.forms(team_id);
CREATE INDEX idx_forms_is_public ON public.forms(is_public);
CREATE INDEX idx_forms_is_template ON public.forms(is_template);
CREATE INDEX idx_forms_status ON public.forms(is_archived);
CREATE INDEX idx_forms_category ON public.forms(category);
CREATE INDEX idx_forms_created_at ON public.forms(created_at DESC);
CREATE INDEX idx_forms_tags ON public.forms USING GIN(tags);

-- Collections
CREATE INDEX idx_collections_user_id ON public.collections(user_id);
CREATE INDEX idx_collections_form_id ON public.collections(form_id);
CREATE INDEX idx_collections_team_id ON public.collections(team_id);
CREATE INDEX idx_collections_status ON public.collections(status);
CREATE INDEX idx_collections_priority ON public.collections(priority);
CREATE INDEX idx_collections_created_at ON public.collections(created_at DESC);
CREATE INDEX idx_collections_submitted_at ON public.collections(submitted_at DESC);
CREATE INDEX idx_collections_tags ON public.collections USING GIN(tags);

-- Sync Queue
CREATE INDEX idx_sync_queue_user_id ON public.sync_queue(user_id);
CREATE INDEX idx_sync_queue_status ON public.sync_queue(status);
CREATE INDEX idx_sync_queue_created_at ON public.sync_queue(created_at);
CREATE INDEX idx_sync_queue_priority_status ON public.sync_queue(priority, status);
CREATE INDEX idx_sync_queue_next_attempt ON public.sync_queue(next_attempt);

-- Notifications
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_type ON public.notifications(type);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- Teams
CREATE INDEX idx_teams_owner_id ON public.teams(owner_id);
CREATE INDEX idx_teams_slug ON public.teams(slug);
CREATE INDEX idx_teams_is_active ON public.teams(is_active);

-- Team Members
CREATE INDEX idx_team_members_team_id ON public.team_members(team_id);
CREATE INDEX idx_team_members_user_id ON public.team_members(user_id);
CREATE INDEX idx_team_members_role ON public.team_members(role);

-- Audit Logs
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_team_id ON public.audit_logs(team_id);
CREATE INDEX idx_audit_logs_resource ON public.audit_logs(resource);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at DESC);

-- Analytics
CREATE INDEX idx_analytics_events_user_id ON public.analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_type ON public.analytics_events(event_type);
CREATE INDEX idx_analytics_events_timestamp ON public.analytics_events(timestamp DESC);

-- Feedback
CREATE INDEX idx_feedback_user_id ON public.feedback(user_id);
CREATE INDEX idx_feedback_type ON public.feedback(type);
CREATE INDEX idx_feedback_status ON public.feedback(status);
CREATE INDEX idx_feedback_created_at ON public.feedback(created_at DESC);

-- Push Tokens
CREATE INDEX idx_push_tokens_user_id ON public.push_tokens(user_id);
CREATE INDEX idx_push_tokens_token ON public.push_tokens(token);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
    ON public.profiles FOR SELECT
    USING (auth.jwt() ->> 'role' = 'admin');

-- Forms Policies
CREATE POLICY "Users can view their own forms"
    ON public.forms FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view public forms"
    ON public.forms FOR SELECT
    USING (is_public = true);

CREATE POLICY "Users can view team forms"
    ON public.forms FOR SELECT
    USING (team_id IN (SELECT team_id FROM public.team_members WHERE user_id = auth.uid()));

CREATE POLICY "Users can create their own forms"
    ON public.forms FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own forms"
    ON public.forms FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own forms"
    ON public.forms FOR DELETE
    USING (auth.uid() = user_id);

-- Collections Policies
CREATE POLICY "Users can view their own collections"
    ON public.collections FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view team collections"
    ON public.collections FOR SELECT
    USING (team_id IN (SELECT team_id FROM public.team_members WHERE user_id = auth.uid()));

CREATE POLICY "Users can create their own collections"
    ON public.collections FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own collections"
    ON public.collections FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own collections"
    ON public.collections FOR DELETE
    USING (auth.uid() = user_id);

-- Sync Queue Policies
CREATE POLICY "Users can view their own sync queue"
    ON public.sync_queue FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own sync queue items"
    ON public.sync_queue FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sync queue items"
    ON public.sync_queue FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sync queue items"
    ON public.sync_queue FOR DELETE
    USING (auth.uid() = user_id);

-- Notifications Policies
CREATE POLICY "Users can view their own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Teams Policies
CREATE POLICY "Users can view teams they belong to"
    ON public.teams FOR SELECT
    USING (id IN (SELECT team_id FROM public.team_members WHERE user_id = auth.uid()));

CREATE POLICY "Owners can update their teams"
    ON public.teams FOR UPDATE
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

-- Team Members Policies
CREATE POLICY "Users can view team members"
    ON public.team_members FOR SELECT
    USING (team_id IN (SELECT team_id FROM public.team_members WHERE user_id = auth.uid()));

CREATE POLICY "Admins can manage team members"
    ON public.team_members FOR ALL
    USING (team_id IN (
        SELECT team_id FROM public.team_members 
        WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    ));

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- 1. Handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url, metadata)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'avatar_url',
        NEW.raw_user_meta_data->'metadata'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Update updated_at column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Update timestamps
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_forms_updated_at
    BEFORE UPDATE ON public.forms
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_collections_updated_at
    BEFORE UPDATE ON public.collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_sync_queue_updated_at
    BEFORE UPDATE ON public.sync_queue
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_teams_updated_at
    BEFORE UPDATE ON public.teams
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_team_members_updated_at
    BEFORE UPDATE ON public.team_members
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 4. Auto-create team member for team owner
CREATE OR REPLACE FUNCTION public.auto_add_team_owner()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.team_members (team_id, user_id, role)
    VALUES (NEW.id, NEW.owner_id, 'owner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_team_created
    AFTER INSERT ON public.teams
    FOR EACH ROW EXECUTE FUNCTION public.auto_add_team_owner();

-- 5. Clean old sync queue items
CREATE OR REPLACE FUNCTION public.clean_old_sync_queue()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.sync_queue
    WHERE status = 'completed' 
    AND processed_at < NOW() - INTERVAL '7 days';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_old_sync_queue_trigger
    AFTER INSERT ON public.sync_queue
    EXECUTE FUNCTION public.clean_old_sync_queue();

-- 6. Archive old notifications
CREATE OR REPLACE FUNCTION public.archive_old_notifications()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.notifications
    SET is_read = true
    WHERE created_at < NOW() - INTERVAL '30 days'
    AND is_read = false;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS
-- =====================================================

-- 1. User Details View
CREATE OR REPLACE VIEW public.user_details AS
SELECT 
    u.id,
    u.email,
    p.full_name,
    p.avatar_url,
    p.company,
    p.job_title,
    p.is_active,
    p.is_verified,
    p.created_at,
    COUNT(DISTINCT c.id) as total_collections,
    COUNT(DISTINCT f.id) as total_forms
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.collections c ON c.user_id = u.id AND c.deleted_at IS NULL
LEFT JOIN public.forms f ON f.user_id = u.id AND f.is_archived = false
GROUP BY u.id, p.full_name, p.avatar_url, p.company, p.job_title, p.is_active, p.is_verified, p.created_at;

-- 2. Collection Analytics View
CREATE OR REPLACE VIEW public.collection_analytics AS
SELECT 
    c.form_id,
    f.title as form_title,
    COUNT(c.id) as total_entries,
    COUNT(CASE WHEN c.status = 'draft' THEN 1 END) as drafts,
    COUNT(CASE WHEN c.status = 'submitted' THEN 1 END) as submitted,
    COUNT(CASE WHEN c.status = 'synced' THEN 1 END) as synced,
    COUNT(CASE WHEN c.status = 'archived' THEN 1 END) as archived,
    AVG(EXTRACT(EPOCH FROM (c.submitted_at - c.created_at))) as avg_submission_time,
    MIN(c.created_at) as first_entry,
    MAX(c.created_at) as last_entry
FROM public.collections c
LEFT JOIN public.forms f ON c.form_id = f.id
WHERE c.deleted_at IS NULL
GROUP BY c.form_id, f.title;

-- 3. Team Activity View
CREATE OR REPLACE VIEW public.team_activity AS
SELECT 
    t.id as team_id,
    t.name as team_name,
    COUNT(DISTINCT tm.user_id) as member_count,
    COUNT(DISTINCT f.id) as form_count,
    COUNT(DISTINCT c.id) as collection_count,
    MAX(c.updated_at) as last_activity
FROM public.teams t
LEFT JOIN public.team_members tm ON t.id = tm.team_id AND tm.deleted_at IS NULL
LEFT JOIN public.forms f ON f.team_id = t.id AND f.is_archived = false
LEFT JOIN public.collections c ON c.team_id = t.id AND c.deleted_at IS NULL
WHERE t.deleted_at IS NULL
GROUP BY t.id, t.name;
```

---

## B.2 API Reference

### B.2.1 Supabase API Endpoints

```typescript
// src/api/endpoints.ts
/**
 * Complete API Reference for NexusCollect
 * 
 * This file documents all API endpoints and their usage.
 */

// Authentication API
export const AUTH_API = {
  // Sign up with email/password
  signUp: '/auth/v1/signup',
  
  // Sign in with email/password
  signIn: '/auth/v1/token?grant_type=password',
  
  // Sign out
  signOut: '/auth/v1/logout',
  
  // Refresh token
  refreshToken: '/auth/v1/token?grant_type=refresh_token',
  
  // Reset password
  resetPassword: '/auth/v1/recover',
  
  // Update user
  updateUser: '/auth/v1/user',
  
  // Send magic link
  magicLink: '/auth/v1/magiclink',
  
  // OAuth providers
  oauth: {
    google: '/auth/v1/authorize?provider=google',
    apple: '/auth/v1/authorize?provider=apple',
    facebook: '/auth/v1/authorize?provider=facebook',
    github: '/auth/v1/authorize?provider=github',
  },
};

// Profiles API
export const PROFILES_API = {
  // Get profile
  get: (userId: string) => `/rest/v1/profiles?id=eq.${userId}`,
  
  // Update profile
  update: (userId: string) => `/rest/v1/profiles?id=eq.${userId}`,
  
  // Get profile by email
  getByEmail: (email: string) => `/rest/v1/profiles?email=eq.${email}`,
  
  // Search profiles
  search: (query: string) => `/rest/v1/profiles?full_name=ilike.*${query}*`,
};

// Forms API
export const FORMS_API = {
  // Get all forms
  getAll: '/rest/v1/forms',
  
  // Get single form
  get: (formId: string) => `/rest/v1/forms?id=eq.${formId}`,
  
  // Create form
  create: '/rest/v1/forms',
  
  // Update form
  update: (formId: string) => `/rest/v1/forms?id=eq.${formId}`,
  
  // Delete form
  delete: (formId: string) => `/rest/v1/forms?id=eq.${formId}`,
  
  // Get public forms
  getPublic: '/rest/v1/forms?is_public=eq.true',
  
  // Get templates
  getTemplates: '/rest/v1/forms?is_template=eq.true',
  
  // Get forms by category
  getByCategory: (category: string) => `/rest/v1/forms?category=eq.${category}`,
  
  // Search forms
  search: (query: string) => `/rest/v1/forms?title=ilike.*${query}*`,
};

// Collections API
export const COLLECTIONS_API = {
  // Get all collections
  getAll: '/rest/v1/collections',
  
  // Get single collection
  get: (collectionId: string) => `/rest/v1/collections?id=eq.${collectionId}`,
  
  // Create collection
  create: '/rest/v1/collections',
  
  // Update collection
  update: (collectionId: string) => `/rest/v1/collections?id=eq.${collectionId}`,
  
  // Delete collection
  delete: (collectionId: string) => `/rest/v1/collections?id=eq.${collectionId}`,
  
  // Get collections by form
  getByForm: (formId: string) => `/rest/v1/collections?form_id=eq.${formId}`,
  
  // Get collections by status
  getByStatus: (status: string) => `/rest/v1/collections?status=eq.${status}`,
  
  // Get collections by date range
  getByDateRange: (start: string, end: string) => 
    `/rest/v1/collections?created_at=gte.${start}&created_at=lte.${end}`,
};

// Sync API
export const SYNC_API = {
  // Get pending sync items
  getPending: '/rest/v1/sync_queue?status=eq.pending',
  
  // Create sync item
  create: '/rest/v1/sync_queue',
  
  // Update sync item
  update: (id: string) => `/rest/v1/sync_queue?id=eq.${id}`,
  
  // Delete sync item
  delete: (id: string) => `/rest/v1/sync_queue?id=eq.${id}`,
  
  // Get sync stats
  getStats: '/rest/v1/sync_queue?select=status,count',
};

// Notifications API
export const NOTIFICATIONS_API = {
  // Get all notifications
  getAll: '/rest/v1/notifications',
  
  // Get unread notifications
  getUnread: '/rest/v1/notifications?is_read=eq.false',
  
  // Mark as read
  markRead: (id: string) => `/rest/v1/notifications?id=eq.${id}`,
  
  // Mark all as read
  markAllRead: '/rest/v1/notifications?is_read=eq.false',
  
  // Create notification
  create: '/rest/v1/notifications',
  
  // Delete notification
  delete: (id: string) => `/rest/v1/notifications?id=eq.${id}`,
};

// Teams API
export const TEAMS_API = {
  // Get all teams
  getAll: '/rest/v1/teams',
  
  // Get single team
  get: (teamId: string) => `/rest/v1/teams?id=eq.${teamId}`,
  
  // Create team
  create: '/rest/v1/teams',
  
  // Update team
  update: (teamId: string) => `/rest/v1/teams?id=eq.${teamId}`,
  
  // Delete team
  delete: (teamId: string) => `/rest/v1/teams?id=eq.${teamId}`,
  
  // Get team members
  getMembers: (teamId: string) => `/rest/v1/team_members?team_id=eq.${teamId}`,
  
  // Add team member
  addMember: '/rest/v1/team_members',
  
  // Remove team member
  removeMember: (memberId: string) => `/rest/v1/team_members?id=eq.${memberId}`,
  
  // Update member role
  updateMember: (memberId: string) => `/rest/v1/team_members?id=eq.${memberId}`,
};
```

### B.2.2 Type Definitions

```typescript
// src/types/api.ts
/**
 * Complete Type Definitions for API Responses
 */

// Auth Types
export interface AuthResponse {
  user: User;
  session: {
    access_token: string;
    refresh_token: string;
    expires_in: number;
    token_type: string;
  };
}

export interface AuthError {
  message: string;
  status: number;
  code?: string;
}

// User Types
export interface User {
  id: string;
  email: string;
  full_name: string;
  avatar_url?: string;
  phone_number?: string;
  company?: string;
  job_title?: string;
  bio?: string;
  website?: string;
  social_links?: Record<string, string>;
  preferences: UserPreferences;
  metadata: Record<string, any>;
  is_active: boolean;
  is_verified: boolean;
  last_login?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  notifications: {
    push: boolean;
    email: boolean;
    sound: boolean;
  };
  language: string;
  timezone: string;
  date_format: string;
}

// Form Types
export interface Form {
  id: string;
  title: string;
  description?: string;
  fields: FormField[];
  user_id: string;
  team_id?: string;
  is_public: boolean;
  is_template: boolean;
  is_archived: boolean;
  version: number;
  category?: string;
  tags: string[];
  settings: FormSettings;
  created_at: Date;
  updated_at: Date;
  published_at?: Date;
  archived_at?: Date;
  metadata: Record<string, any>;
}

export interface FormField {
  id: string;
  label: string;
  type: 'text' | 'number' | 'date' | 'select' | 'checkbox' | 'photo' | 'location' | 'signature';
  required: boolean;
  options?: string[];
  defaultValue?: any;
  placeholder?: string;
  validation?: {
    min?: number;
    max?: number;
    pattern?: string;
    custom?: string;
  };
  metadata?: Record<string, any>;
}

export interface FormSettings {
  allow_editing: boolean;
  allow_photos: boolean;
  allow_location: boolean;
  allow_signature: boolean;
  require_approval: boolean;
  notify_on_submit: boolean;
}

// Collection Types
export interface Collection {
  id: string;
  form_id: string;
  user_id: string;
  team_id?: string;
  data: Record<string, any>;
  location?: Location;
  photos: string[];
  videos: string[];
  audio: string[];
  signature?: Signature;
  status: 'draft' | 'submitted' | 'synced' | 'archived' | 'rejected';
  priority: 'low' | 'normal' | 'high' | 'urgent';
  tags: string[];
  notes?: string;
  synced_at?: Date;
  submitted_at?: Date;
  reviewed_at?: Date;
  reviewed_by?: string;
  created_at: Date;
  updated_at: Date;
  deleted_at?: Date;
  metadata: Record<string, any>;
}

export interface Location {
  latitude: number;
  longitude: number;
  accuracy?: number;
  altitude?: number;
  speed?: number;
  heading?: number;
  address?: string;
}

export interface Signature {
  data: string; // Base64 encoded image
  timestamp: Date;
  signer_name: string;
}

// Team Types
export interface Team {
  id: string;
  name: string;
  slug: string;
  description?: string;
  logo_url?: string;
  banner_url?: string;
  owner_id: string;
  is_active: boolean;
  settings: TeamSettings;
  created_at: Date;
  updated_at: Date;
  deleted_at?: Date;
}

export interface TeamSettings {
  allow_public_forms: boolean;
  require_approval: boolean;
  notify_on_join: boolean;
}

export interface TeamMember {
  id: string;
  team_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'editor' | 'viewer';
  permissions: Record<string, any>;
  joined_at: Date;
  created_at: Date;
  updated_at: Date;
  deleted_at?: Date;
}

// Notification Types
export interface Notification {
  id: string;
  user_id: string;
  type: 'sync' | 'mention' | 'update' | 'alert' | 'reminder' | 'info' | 'error';
  title: string;
  body: string;
  data?: Record<string, any>;
  link?: string;
  image_url?: string;
  is_read: boolean;
  is_actionable: boolean;
  action_buttons?: NotificationAction[];
  priority: 'low' | 'normal' | 'high';
  read_at?: Date;
  created_at: Date;
  expires_at?: Date;
}

export interface NotificationAction {
  id: string;
  label: string;
  action: string;
  data?: Record<string, any>;
}

// API Response Wrapper
export interface ApiResponse<T> {
  data: T;
  error?: ApiError;
  status: number;
  pagination?: Pagination;
}

export interface ApiError {
  message: string;
  code: string;
  status: number;
  details?: Record<string, any>;
}

export interface Pagination {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

// Query Parameters
export interface QueryParams {
  limit?: number;
  offset?: number;
  order?: 'asc' | 'desc';
  order_by?: string;
  filter?: Record<string, any>;
  search?: string;
}
```

---

## B.3 Database Migration History

### B.3.1 Migration Version History

| Version | Date | Description | Changes |
|---------|------|-------------|---------|
| 1.0.0 | 2024-01-01 | Initial Schema | Created all core tables |
| 1.1.0 | 2024-01-15 | Add Team Support | Added teams, team_members tables |
| 1.2.0 | 2024-02-01 | Add Analytics | Added analytics_events table |
| 1.3.0 | 2024-02-15 | Add Feedback | Added feedback table |
| 1.4.0 | 2024-03-01 | Add Push Tokens | Added push_tokens table |
| 1.5.0 | 2024-03-15 | Add User Sessions | Added user_sessions table |
| 1.6.0 | 2024-04-01 | Add Media Support | Added videos, audio columns to collections |
| 1.7.0 | 2024-04-15 | Add Priority | Added priority column to collections |
| 1.8.0 | 2024-05-01 | Add Tags | Added tags column to forms and collections |
| 1.9.0 | 2024-05-15 | Add Signature | Added signature column to collections |

### B.3.2 Migration Examples

```sql
-- Migration 1.1.0: Add Team Support
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    settings JSONB DEFAULT '{"allow_public_forms": false, "require_approval": true}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'editor', 'viewer')),
    permissions JSONB DEFAULT '{}'::jsonb,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Add team_id to forms
ALTER TABLE public.forms ADD COLUMN team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL;

-- Add team_id to collections
ALTER TABLE public.collections ADD COLUMN team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL;

-- Migration 1.2.0: Add Analytics
CREATE TABLE IF NOT EXISTS public.analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_name TEXT NOT NULL,
    session_id TEXT,
    device_info JSONB,
    properties JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

---

## B.4 Seed Data

### B.4.1 Sample Form Templates

```sql
-- Seed: Sample Form Templates

INSERT INTO public.forms (title, description, fields, user_id, is_template, is_public, category, tags)
VALUES 
(
    'Customer Feedback Survey',
    'Collect feedback from customers about their experience',
    '[
        {"id": "name", "label": "Customer Name", "type": "text", "required": true},
        {"id": "email", "label": "Email Address", "type": "text", "required": true},
        {"id": "rating", "label": "Overall Rating", "type": "select", "required": true, "options": ["1 ★", "2 ★★", "3 ★★★", "4 ★★★★", "5 ★★★★★"]},
        {"id": "feedback", "label": "Feedback / Suggestions", "type": "text", "required": false},
        {"id": "photo", "label": "Photo (Optional)", "type": "photo", "required": false}
    ]'::jsonb,
    (SELECT id FROM auth.users LIMIT 1),
    true,
    true,
    'Feedback',
    ARRAY['customer', 'feedback', 'survey']
),
(
    'Site Inspection Report',
    'Comprehensive site inspection form for construction and maintenance',
    '[
        {"id": "site_name", "label": "Site Name", "type": "text", "required": true},
        {"id": "site_location", "label": "Site Location", "type": "location", "required": true},
        {"id": "inspection_type", "label": "Inspection Type", "type": "select", "required": true, "options": ["Safety", "Quality", "Compliance", "Routine"]},
        {"id": "findings", "label": "Findings", "type": "text", "required": true},
        {"id": "severity", "label": "Severity", "type": "select", "required": true, "options": ["Low", "Medium", "High", "Critical"]},
        {"id": "photos", "label": "Site Photos", "type": "photo", "required": false},
        {"id": "signature", "label": "Inspector Signature", "type": "signature", "required": true}
    ]'::jsonb,
    (SELECT id FROM auth.users LIMIT 1),
    true,
    true,
    'Inspection',
    ARRAY['inspection', 'construction', 'safety']
),
(
    'Equipment Maintenance Log',
    'Track maintenance and service records for equipment',
    '[
        {"id": "equipment_id", "label": "Equipment ID", "type": "text", "required": true},
        {"id": "equipment_name", "label": "Equipment Name", "type": "text", "required": true},
        {"id": "maintenance_date", "label": "Maintenance Date", "type": "date", "required": true},
        {"id": "maintenance_type", "label": "Maintenance Type", "type": "select", "required": true, "options": ["Routine", "Preventive", "Corrective", "Emergency"]},
        {"id": "technician", "label": "Technician Name", "type": "text", "required": true},
        {"id": "notes", "label": "Maintenance Notes", "type": "text", "required": false},
        {"id": "parts_used", "label": "Parts Used", "type": "text", "required": false},
        {"id": "photos", "label": "Photos (Optional)", "type": "photo", "required": false}
    ]'::jsonb,
    (SELECT id FROM auth.users LIMIT 1),
    true,
    true,
    'Maintenance',
    ARRAY['equipment', 'maintenance', 'service']
),
(
    'Incident Report',
    'Report workplace incidents, accidents, or near-misses',
    '[
        {"id": "reporter", "label": "Reporter Name", "type": "text", "required": true},
        {"id": "date_time", "label": "Date and Time", "type": "date", "required": true},
        {"id": "incident_type", "label": "Incident Type", "type": "select", "required": true, "options": ["Accident", "Near Miss", "Injury", "Property Damage", "Environmental"]},
        {"id": "location", "label": "Incident Location", "type": "location", "required": true},
        {"id": "description", "label": "Incident Description", "type": "text", "required": true},
        {"id": "severity", "label": "Severity", "type": "select", "required": true, "options": ["Low", "Medium", "High", "Critical"]},
        {"id": "photos", "label": "Photos (Optional)", "type": "photo", "required": false},
        {"id": "signature", "label": "Reporter Signature", "type": "signature", "required": true}
    ]'::jsonb,
    (SELECT id FROM auth.users LIMIT 1),
    true,
    true,
    'Incident',
    ARRAY['incident', 'safety', 'accident']
);
```

---

## B.5 Performance Optimization Guide

### B.5.1 Query Optimization Tips

```sql
-- 1. Use EXPLAIN ANALYZE to analyze query performance
EXPLAIN ANALYZE
SELECT * FROM public.collections
WHERE user_id = 'some-uuid'
AND status = 'submitted'
ORDER BY created_at DESC
LIMIT 100;

-- 2. Create composite indexes for common queries
CREATE INDEX idx_collections_user_status ON public.collections(user_id, status);
CREATE INDEX idx_collections_user_form ON public.collections(user_id, form_id);
CREATE INDEX idx_collections_status_created ON public.collections(status, created_at DESC);

-- 3. Use partial indexes for filtered queries
CREATE INDEX idx_collections_submitted_active 
ON public.collections(user_id, created_at DESC)
WHERE status = 'submitted' AND deleted_at IS NULL;

-- 4. Use covering indexes to avoid table scans
CREATE INDEX idx_collections_covering 
ON public.collections(user_id, status, created_at DESC) 
INCLUDE (id, data, location);

-- 5. Analyze tables to update statistics
ANALYZE public.collections;
ANALYZE public.forms;
ANALYZE public.profiles;
```

### B.5.2 Performance Best Practices

```typescript
/**
 * Performance Optimization Guidelines
 */

export const PERFORMANCE_GUIDELINES = {
  // Query Guidelines
  queries: {
    limitResults: 'Always use LIMIT on queries',
    useIndexes: 'Ensure queries use appropriate indexes',
    avoidSelectStar: 'Select only needed columns',
    useBatching: 'Batch multiple queries when possible',
  },
  
  // Data Management
  dataManagement: {
    archiveOldData: 'Archive data older than 90 days',
    purgeDeleted: 'Remove soft-deleted data after 30 days',
    optimizePagination: 'Use keyset pagination for large datasets',
  },
  
  // API Guidelines
  api: {
    cacheResponses: 'Cache frequently accessed data',
    compressResponses: 'Enable gzip compression',
    usePagination: 'Always paginate list endpoints',
    rateLimit: 'Implement rate limiting for API endpoints',
  },
  
  // Database Guidelines
  database: {
    connectionPooling: 'Use connection pooling',
    transactionManagement: 'Keep transactions short',
    avoidNPlus1: 'Use eager loading to avoid N+1 queries',
    useMaterializedViews: 'Use materialized views for complex analytics',
  },
};
```

---

This appendix provides a complete reference for all database schemas, API endpoints, and data models used in the NexusCollect application. Use it as a comprehensive guide for development and troubleshooting.

---

**[END OF APPENDIX B]**
