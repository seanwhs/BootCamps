# Part 17: Role-Based Access Control

## Implementing Role-Based Permissions Across the Stack

Welcome to **Part 17** of the Django REST Framework & Next.js 16 masterclass. Now that we have our permission system in place, we'll implement a comprehensive Role-Based Access Control (RBAC) system. We'll define user roles, their capabilities, and implement both backend and frontend checks.

In this part, we'll:
- Define roles and their capabilities
- Implement role-based permissions on the backend
- Build role-based UI components
- Implement frontend route protection by role
- Create admin interfaces for role management

Think of RBAC as **organizational structure** for your application. Just as companies have different job titles with different responsibilities (CEO, Manager, Employee), your application has different user roles with different permissions.

---

## The Target

We'll build a complete RBAC system:

```
Role Hierarchy:
┌─────────────────────────────────────────────────────────────┐
│                     Role Capabilities                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ADMIN: All permissions                                      │
│    ├─ Manage users (create, edit, delete, assign roles)     │
│    ├─ Manage all projects and tasks                         │
│    ├─ Manage all comments                                   │
│    └─ Access all settings                                   │
│                                                              │
│  MANAGER: Project management                                 │
│    ├─ Manage users (view only)                              │
│    ├─ Create, edit, delete projects                         │
│    ├─ Create, edit, delete tasks in their projects          │
│    ├─ Assign tasks to members                               │
│    └─ Access project settings                               │
│                                                              │
│  MEMBER: Task execution                                      │
│    ├─ View projects they're assigned to                     │
│    ├─ Create tasks in their projects                        │
│    ├─ Update assigned tasks                                 │
│    └─ Add comments                                          │
│                                                              │
│  VIEWER: Read-only                                           │
│    ├─ View projects they're assigned to                     │
│    ├─ View tasks                                            │
│    └─ View comments                                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## The Concept

### Role-Based Access Control

RBAC is a method of restricting system access based on roles:

```python
# Role definitions
class Roles:
    ADMIN = 'admin'
    MANAGER = 'manager'
    MEMBER = 'member'
    VIEWER = 'viewer'

# Role capabilities
ROLE_PERMISSIONS = {
    Roles.ADMIN: ['all'],
    Roles.MANAGER: ['manage_projects', 'manage_tasks', 'view_users'],
    Roles.MEMBER: ['view_projects', 'manage_own_tasks', 'add_comments'],
    Roles.VIEWER: ['view_projects', 'view_tasks', 'view_comments'],
}
```

### Permission Checking Flow

```
User Request
     ↓
Check Authentication
     ↓
Check User Role
     ↓
Check Permission
     ↓
Access Granted/Denied
```

### Role-Based UI

```
Admin User:     Sees all navigation items, admin dashboard
Manager User:   Sees project management, reports
Member User:    Sees assigned tasks, project dashboard
Viewer User:    Sees read-only views
```

---

## The Implementation

### Step 1: Update User Model with Role Methods

**backend/apps/users/models.py** (update)

```python
"""
Custom User model extending Django's AbstractUser.
"""

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _

from .managers import UserManager


class User(AbstractUser):
    """
    Custom User model with additional fields and role-based methods.
    """
    
    class Roles(models.TextChoices):
        ADMIN = 'admin', _('Administrator')
        MANAGER = 'manager', _('Manager')
        MEMBER = 'member', _('Member')
        VIEWER = 'viewer', _('Viewer')

    email = models.EmailField(_('email address'), unique=True)
    bio = models.TextField(_('bio'), blank=True, null=True)
    role = models.CharField(
        _('role'),
        max_length=20,
        choices=Roles.choices,
        default=Roles.MEMBER,
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']

    def __str__(self):
        return self.email

    def get_full_name(self):
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.email

    @property
    def is_admin(self):
        return self.role == self.Roles.ADMIN or self.is_superuser

    @property
    def is_manager(self):
        return self.role in [self.Roles.ADMIN, self.Roles.MANAGER]

    @property
    def is_member(self):
        return self.role in [self.Roles.ADMIN, self.Roles.MANAGER, self.Roles.MEMBER]

    def has_role(self, *roles):
        """Check if user has any of the specified roles."""
        return self.role in roles

    def has_permission(self, permission):
        """Check if user has a specific permission."""
        permissions = {
            'manage_users': self.is_admin,
            'manage_roles': self.is_admin,
            'view_users': self.is_manager or self.is_admin,
            'manage_projects': self.is_manager or self.is_admin,
            'manage_all_tasks': self.is_manager or self.is_admin,
            'manage_own_tasks': self.is_member,
            'view_projects': self.is_member,
            'view_tasks': self.is_member,
            'view_comments': self.is_member,
            'add_comments': self.is_member,
            'delete_own_comments': self.is_member,
        }
        return permissions.get(permission, False)

    def has_project_access(self, project):
        """Check if user has access to a project."""
        if self.is_admin:
            return True
        if project.created_by == self:
            return True
        if project.tasks.filter(assigned_to=self).exists():
            return True
        return False

    def has_task_access(self, task):
        """Check if user has access to a task."""
        if self.is_admin:
            return True
        if task.created_by == self:
            return True
        if task.assigned_to == self:
            return True
        if task.project.created_by == self:
            return True
        return False

    def can_edit_task(self, task):
        """Check if user can edit a task."""
        if self.is_admin:
            return True
        if self.is_manager and task.project.created_by == self:
            return True
        if task.assigned_to == self:
            return True
        return False

    def can_delete_task(self, task):
        """Check if user can delete a task."""
        if self.is_admin:
            return True
        if self.is_manager and task.project.created_by == self:
            return True
        if task.created_by == self:
            return True
        return False

    def can_edit_comment(self, comment):
        """Check if user can edit a comment."""
        if self.is_admin:
            return True
        return comment.author == self

    def can_delete_comment(self, comment):
        """Check if user can delete a comment."""
        if self.is_admin:
            return True
        if self.is_manager and comment.task.project.created_by == self:
            return True
        return comment.author == self
```

### Step 2: Create Role-Based Permission Classes

**backend/apps/api/permissions.py** (add role-based permissions)

```python
"""
Custom permission classes for the API including role-based permissions.
"""

from rest_framework import permissions
from apps.users.models import User


class IsAuthenticated(permissions.IsAuthenticated):
    """Standard authentication check."""
    pass


class IsAdminUser(permissions.IsAdminUser):
    """Allows access only to admin users."""
    pass


class IsManagerOrHigher(permissions.BasePermission):
    """Allows access only to users with manager role or higher."""
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.role in [User.Roles.ADMIN, User.Roles.MANAGER]


class IsMemberOrHigher(permissions.BasePermission):
    """Allows access only to users with member role or higher."""
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.role in [User.Roles.ADMIN, User.Roles.MANAGER, User.Roles.MEMBER]


class IsAdminOrManager(permissions.BasePermission):
    """Allows access to admin and manager users."""
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.role in [User.Roles.ADMIN, User.Roles.MANAGER]


class CanManageUsers(permissions.BasePermission):
    """Allows access only to users who can manage other users."""
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Admin can manage all users
        if request.user.role == User.Roles.ADMIN:
            return True
        
        # Manager can manage users but not admins
        if request.user.role == User.Roles.MANAGER:
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        # obj is a User instance
        
        # Admin can manage all users
        if request.user.role == User.Roles.ADMIN:
            return True
        
        # Manager can manage non-admin users
        if request.user.role == User.Roles.MANAGER:
            return obj.role != User.Roles.ADMIN
        
        return False


# ... (keep existing permission classes from Part 16)
```

### Step 3: Create Role-Based UI Components

**frontend/lib/auth/roles.ts** (create)

```tsx
/**
 * Role definitions and utilities
 */

export const ROLES = {
  ADMIN: 'admin',
  MANAGER: 'manager',
  MEMBER: 'member',
  VIEWER: 'viewer',
} as const;

export type Role = typeof ROLES[keyof typeof ROLES];

export const ROLE_LABELS: Record<Role, string> = {
  [ROLES.ADMIN]: 'Administrator',
  [ROLES.MANAGER]: 'Manager',
  [ROLES.MEMBER]: 'Member',
  [ROLES.VIEWER]: 'Viewer',
};

export const ROLE_HIERARCHY: Record<Role, number> = {
  [ROLES.ADMIN]: 4,
  [ROLES.MANAGER]: 3,
  [ROLES.MEMBER]: 2,
  [ROLES.VIEWER]: 1,
};

/**
 * Check if a user has a specific role
 */
export function hasRole(user: any, role: Role): boolean {
  return user?.role === role;
}

/**
 * Check if a user has at least a specific role level
 */
export function hasRoleOrHigher(user: any, minRole: Role): boolean {
  if (!user) return false;
  const userLevel = ROLE_HIERARCHY[user.role as Role] || 0;
  const minLevel = ROLE_HIERARCHY[minRole];
  return userLevel >= minLevel;
}

/**
 * Check if a user can manage users
 */
export function canManageUsers(user: any): boolean {
  if (!user) return false;
  return user.role === ROLES.ADMIN || user.role === ROLES.MANAGER;
}

/**
 * Check if a user can manage projects
 */
export function canManageProjects(user: any): boolean {
  if (!user) return false;
  return user.role === ROLES.ADMIN || user.role === ROLES.MANAGER;
}

/**
 * Check if a user can view all users
 */
export function canViewAllUsers(user: any): boolean {
  if (!user) return false;
  return user.role === ROLES.ADMIN || user.role === ROLES.MANAGER;
}

/**
 * Get user display name
 */
export function getUserDisplayName(user: any): string {
  if (!user) return 'Unknown User';
  if (user.first_name || user.last_name) {
    return `${user.first_name || ''} ${user.last_name || ''}`.trim();
  }
  return user.email || user.username || 'User';
}

/**
 * Get user initials for avatar
 */
export function getUserInitials(user: any): string {
  if (!user) return 'U';
  if (user.first_name && user.last_name) {
    return `${user.first_name[0]}${user.last_name[0]}`.toUpperCase();
  }
  if (user.first_name) {
    return user.first_name[0].toUpperCase();
  }
  if (user.username) {
    return user.username[0].toUpperCase();
  }
  return 'U';
}
```

### Step 4: Create Role-Based Component

**frontend/components/auth/RoleGuard.tsx** (create)

```tsx
'use client';

import { ReactNode } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Role, hasRole, hasRoleOrHigher, canManageUsers, canManageProjects } from '@/lib/auth/roles';

interface RoleGuardProps {
  children: ReactNode;
  roles?: Role[];
  minRole?: Role;
  fallback?: ReactNode;
}

export function RoleGuard({ 
  children, 
  roles, 
  minRole, 
  fallback = null 
}: RoleGuardProps) {
  const { user } = useAuth();

  if (!user) {
    return <>{fallback}</>;
  }

  // Check if user has any of the specified roles
  if (roles && roles.length > 0) {
    const hasRequiredRole = roles.some(role => hasRole(user, role));
    if (!hasRequiredRole) {
      return <>{fallback}</>;
    }
  }

  // Check if user has at least the minimum role level
  if (minRole) {
    if (!hasRoleOrHigher(user, minRole)) {
      return <>{fallback}</>;
    }
  }

  return <>{children}</>;
}

export function AdminGuard({ children, fallback }: { children: ReactNode; fallback?: ReactNode }) {
  return (
    <RoleGuard roles={['admin']} fallback={fallback}>
      {children}
    </RoleGuard>
  );
}

export function ManagerGuard({ children, fallback }: { children: ReactNode; fallback?: ReactNode }) {
  return (
    <RoleGuard minRole="manager" fallback={fallback}>
      {children}
    </RoleGuard>
  );
}

export function MemberGuard({ children, fallback }: { children: ReactNode; fallback?: ReactNode }) {
  return (
    <RoleGuard minRole="member" fallback={fallback}>
      {children}
    </RoleGuard>
  );
}
```

### Step 5: Create Permission Hook

**frontend/hooks/usePermissions.ts** (create)

```tsx
'use client';

import { useAuth } from './useAuth';
import { 
  hasRole, 
  hasRoleOrHigher, 
  canManageUsers, 
  canManageProjects,
  canViewAllUsers,
  Role,
  ROLES
} from '@/lib/auth/roles';

export function usePermissions() {
  const { user } = useAuth();

  return {
    user,
    
    // Role checks
    isAdmin: hasRole(user, ROLES.ADMIN),
    isManager: hasRole(user, ROLES.MANAGER),
    isMember: hasRole(user, ROLES.MEMBER),
    isViewer: hasRole(user, ROLES.VIEWER),
    
    // Role level checks
    isAdminOrHigher: hasRoleOrHigher(user, ROLES.ADMIN),
    isManagerOrHigher: hasRoleOrHigher(user, ROLES.MANAGER),
    isMemberOrHigher: hasRoleOrHigher(user, ROLES.MEMBER),
    
    // Permission checks
    canManageUsers: canManageUsers(user),
    canManageProjects: canManageProjects(user),
    canViewAllUsers: canViewAllUsers(user),
    
    // Helper methods
    hasRole: (role: Role) => hasRole(user, role),
    hasRoleOrHigher: (role: Role) => hasRoleOrHigher(user, role),
  };
}
```

### Step 6: Update Dashboard Navigation with Role-Based Items

**frontend/app/(dashboard)/layout.tsx** (update with role-based navigation)

```tsx
'use client';

import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { RoleGuard } from '@/components/auth/RoleGuard';
import { useAuth } from '@/hooks/useAuth';
import { usePermissions } from '@/hooks/usePermissions';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  FolderKanban, 
  ListTodo, 
  Users, 
  Settings,
  LogOut,
  UserCog,
  Shield
} from 'lucide-react';
import { cn } from '@/lib/utils/helpers';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const { isAdmin, isManagerOrHigher } = usePermissions();

  const baseNavigation = [
    { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Projects', href: '/projects', icon: FolderKanban },
    { name: 'Tasks', href: '/tasks', icon: ListTodo },
  ];

  // Role-based navigation items
  const adminOnly = [
    { name: 'Users', href: '/users', icon: Users },
    { name: 'Admin', href: '/admin', icon: Shield },
  ];

  const managerOnly = [
    { name: 'Users', href: '/users', icon: Users },
  ];

  let navigation = [...baseNavigation];
  
  if (isAdmin) {
    navigation = [...navigation, ...adminOnly];
  } else if (isManagerOrHigher) {
    navigation = [...navigation, ...managerOnly];
  }

  // Settings is always visible
  navigation.push({ name: 'Settings', href: '/settings', icon: Settings });

  const handleLogout = () => {
    logout();
  };

  return (
    <ProtectedRoute>
      <div className="flex min-h-screen">
        {/* Sidebar */}
        <aside className="fixed inset-y-0 left-0 z-50 w-64 border-r border-secondary-200 bg-white">
          <div className="flex h-full flex-col">
            <div className="flex h-16 items-center border-b border-secondary-200 px-6">
              <Link href="/dashboard" className="text-xl font-bold text-primary-600">
                TaskFlow
              </Link>
            </div>
            <nav className="flex-1 space-y-1 p-4">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href || pathname?.startsWith(item.href + '/');
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                      'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                      isActive
                        ? 'bg-primary-50 text-primary-700'
                        : 'text-secondary-700 hover:bg-secondary-100 hover:text-secondary-900'
                    )}
                  >
                    <Icon className="h-5 w-5" />
                    {item.name}
                  </Link>
                );
              })}
            </nav>
            <div className="border-t border-secondary-200 p-4">
              <div className="flex items-center gap-3">
                <div className="h-8 w-8 rounded-full bg-primary-100 text-primary-600 flex items-center justify-center">
                  {user?.first_name?.[0] || user?.email?.[0] || 'U'}
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">
                    {user?.first_name ? `${user.first_name} ${user.last_name || ''}` : user?.email}
                  </p>
                  <p className="text-xs text-secondary-500">
                    {user?.role_display || user?.role}
                  </p>
                </div>
                <button
                  onClick={handleLogout}
                  className="rounded-md p-1 text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600"
                  aria-label="Logout"
                >
                  <LogOut className="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 pl-64">
          <header className="sticky top-0 z-40 border-b border-secondary-200 bg-white/80 backdrop-blur">
            <div className="flex h-16 items-center justify-between px-6">
              <h1 className="text-xl font-semibold text-secondary-900">
                {navigation.find(n => n.href === pathname)?.name || 'Dashboard'}
              </h1>
            </div>
          </header>
          <div className="p-6">{children}</div>
        </main>
      </div>
    </ProtectedRoute>
  );
}
```

### Step 7: Create Admin Users Page with Role Management

**frontend/app/(dashboard)/admin/page.tsx** (create)

```tsx
'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useAuth } from '@/hooks/useAuth';
import { usePermissions } from '@/hooks/usePermissions';
import { ROLES, ROLE_LABELS } from '@/lib/auth/roles';
import { useToast } from '@/lib/context/ToastContext';
import { get, patch } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';

export default function AdminPage() {
  const { addToast } = useToast();
  const { isAdmin } = usePermissions();
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Only admins can access this page
  if (!isAdmin) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-danger-600">
          You don't have permission to access this page.
        </CardContent>
      </Card>
    );
  }

  // Fetch users on mount
  useState(() => {
    const fetchUsers = async () => {
      const response = await get(ENDPOINTS.users.list);
      if (response.data) {
        setUsers(response.data);
      }
      setLoading(false);
    };
    fetchUsers();
  }, []);

  const handleRoleChange = async (userId: number, newRole: string) => {
    try {
      const response = await patch(
        ENDPOINTS.users.setRole(userId),
        { role: newRole }
      );
      
      if (response.error) {
        addToast('Failed to update role', 'error');
        return;
      }
      
      setUsers(users.map(u => 
        u.id === userId ? { ...u, role: newRole, role_display: ROLE_LABELS[newRole as keyof typeof ROLE_LABELS] } : u
      ));
      addToast('Role updated successfully', 'success');
    } catch (error) {
      addToast('An error occurred', 'error');
    }
  };

  const getRoleBadgeColor = (role: string) => {
    const colors = {
      [ROLES.ADMIN]: 'bg-purple-100 text-purple-700',
      [ROLES.MANAGER]: 'bg-blue-100 text-blue-700',
      [ROLES.MEMBER]: 'bg-green-100 text-green-700',
      [ROLES.VIEWER]: 'bg-gray-100 text-gray-700',
    };
    return colors[role as keyof typeof colors] || 'bg-secondary-100 text-secondary-700';
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Admin Dashboard</h1>
      
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{users.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Admins</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {users.filter(u => u.role === ROLES.ADMIN).length}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Managers</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {users.filter(u => u.role === ROLES.MANAGER).length}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>User Management</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-secondary-500">Loading users...</p>
          ) : users.length === 0 ? (
            <p className="text-secondary-500">No users found</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-secondary-200">
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">User</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Email</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Current Role</th>
                    <th className="px-4 py-2 text-left text-sm font-medium text-secondary-600">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => (
                    <tr key={user.id} className="border-b border-secondary-100">
                      <td className="px-4 py-3 text-sm">
                        {user.first_name} {user.last_name}
                      </td>
                      <td className="px-4 py-3 text-sm">{user.email}</td>
                      <td className="px-4 py-3 text-sm">
                        <Badge className={getRoleBadgeColor(user.role)}>
                          {user.role_display}
                        </Badge>
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <select
                          value={user.role}
                          onChange={(e) => handleRoleChange(user.id, e.target.value)}
                          className="rounded-md border border-secondary-300 px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                          disabled={user.id === 1} // Prevent changing superadmin
                        >
                          {Object.entries(ROLE_LABELS).map(([value, label]) => (
                            <option key={value} value={value}>
                              {label}
                            </option>
                          ))}
                        </select>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
```

### Step 8: Update Project List with Role-Based Actions

**frontend/app/(dashboard)/projects/components/ProjectList.tsx** (update with role-based actions)

```tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Plus, Pencil, Trash2, UserPlus } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { Modal } from '@/components/ui/Modal';
import { useProjects, useDeleteProject } from '@/lib/api/hooks';
import { usePermissions } from '@/hooks/usePermissions';
import { useToast } from '@/lib/context/ToastContext';

export function ProjectList() {
  const router = useRouter();
  const { addToast } = useToast();
  const { isAdmin, isManagerOrHigher } = usePermissions();
  const { data, isLoading, error, refetch } = useProjects();
  const deleteProject = useDeleteProject();
  
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [projectToDelete, setProjectToDelete] = useState<any>(null);

  const projects = data?.results || [];

  const handleDeleteClick = (project: any) => {
    if (project.created_by === useAuth().user?.id || isAdmin) {
      setProjectToDelete(project);
      setDeleteModalOpen(true);
    } else {
      addToast('You do not have permission to delete this project', 'error');
    }
  };

  const confirmDelete = async () => {
    if (!projectToDelete) return;
    
    const result = await deleteProject.mutateAsync(projectToDelete.id);
    if (!result.error) {
      addToast('Project deleted successfully', 'success');
      refetch();
    }
    setDeleteModalOpen(false);
    setProjectToDelete(null);
  };

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return <div>Error loading projects: {error.message}</div>;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-semibold">Projects</h2>
        {(isAdmin || isManagerOrHigher) && (
          <Link href="/projects/create">
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              New Project
            </Button>
          </Link>
        )}
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {projects.map((project) => (
          <Card key={project.id} className="card-hover">
            <CardHeader>
              <div className="flex items-start justify-between">
                <Link href={`/projects/${project.id}`} className="flex-1">
                  <CardTitle className="hover:text-primary-600">
                    {project.name}
                  </CardTitle>
                </Link>
                {(isAdmin || project.created_by === useAuth().user?.id) && (
                  <div className="flex gap-1">
                    <Link href={`/projects/${project.id}/edit`}>
                      <Button variant="ghost" size="sm">
                        <Pencil className="h-4 w-4" />
                      </Button>
                    </Link>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDeleteClick(project)}
                    >
                      <Trash2 className="h-4 w-4 text-danger-500" />
                    </Button>
                  </div>
                )}
              </div>
            </CardHeader>
            <CardContent>
              {project.description && (
                <p className="text-sm text-secondary-600 line-clamp-2">
                  {project.description}
                </p>
              )}
              <div className="mt-4 flex items-center justify-between">
                <div className="flex gap-2">
                  <Badge variant="secondary">
                    {project.task_count} tasks
                  </Badge>
                  {project.completed_task_count > 0 && (
                    <Badge variant="success">
                      {project.completed_task_count} completed
                    </Badge>
                  )}
                </div>
                <span className="text-xs text-secondary-400">
                  Created by {project.created_by_username}
                </span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Modal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={confirmDelete}
        title="Delete Project"
        description={`Are you sure you want to delete "${projectToDelete?.name}"? This action cannot be undone.`}
        confirmText="Delete Project"
        variant="danger"
      />
    </div>
  );
}
```

---

## The Verification

### Step 1: Start the Servers

```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate
python manage.py runserver

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### Step 2: Test Different User Roles

**Create users with different roles:**

```bash
# Create admin
python manage.py createsuperuser

# Create manager, member, viewer through registration API
curl -X POST http://localhost:8000/api/v1/users/register/ \
  -H "Content-Type: application/json" \
  -d '{"email": "manager@example.com", "username": "manager", "password": "pass123!", "confirm_password": "pass123!"}'

# Then update role via admin or API
```

### Step 3: Test Role-Based Access

1. Login as **Admin**:
   - ✅ See Users and Admin in navigation
   - ✅ Can delete any project
   - ✅ Can change user roles

2. Login as **Manager**:
   - ✅ See Users in navigation
   - ✅ Can create/edit/delete projects they own
   - ✅ Can view all users
   - ❌ Cannot access Admin page

3. Login as **Member**:
   - ✅ See Dashboard, Projects, Tasks
   - ✅ Can view projects they have access to
   - ✅ Can edit tasks assigned to them
   - ❌ Cannot see Users in navigation
   - ❌ Cannot create new projects (if configured)

### Step 4: Test Admin Page

1. Login as admin
2. Go to /admin
3. ✅ See user management table
4. ✅ Change user roles
5. ✅ Changes persist

### Step 5: Test Protected UI Elements

1. Edit/Delete buttons on projects:
   - ✅ Admin sees all
   - ✅ Owner sees on their projects
   - ❌ Other users don't see

2. Navigation items:
   - ✅ Admin sees all items
   - ✅ Manager sees limited items
   - ❌ Member sees only basic items

---

## Key Takeaways

1. **Role-Based Access Control** provides granular control over user capabilities.

2. **Role hierarchy** (Admin > Manager > Member > Viewer) simplifies permission management.

3. **Backend permissions** are the primary security boundary.

4. **Frontend guards** provide a better UX by hiding unauthorized content.

5. **Role-based navigation** adapts the UI to the user's permissions.

6. **Admin interfaces** should only be accessible to users with the appropriate role.

---

## What's Next

In **Part 18**, we'll implement Next.js authentication integration:

- Next.js middleware for route protection
- Server-side authentication
- API route protection
- Authentication flows in server components

---

**End of Part 17**

*Next: Part 18 - Next.js Authentication*
