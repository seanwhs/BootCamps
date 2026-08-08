# Appendix N: Django ORM Cheat Sheet

## Quick Reference for Django ORM Operations

Welcome to **Appendix N** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a quick reference for common Django ORM operations, patterns, and best practices.

---

## Section 1: Basic CRUD Operations

### Create

```python
# Create a single object
task = Task.objects.create(
    title='Complete documentation',
    project=project,
    created_by=user
)

# Create with save()
task = Task(title='Complete documentation')
task.save()

# Get or create
task, created = Task.objects.get_or_create(
    title='Complete documentation',
    defaults={'priority': 'high'}
)

# Bulk create
tasks = [
    Task(title='Task 1', project=project),
    Task(title='Task 2', project=project),
    Task(title='Task 3', project=project),
]
Task.objects.bulk_create(tasks)

# Update or create
task, created = Task.objects.update_or_create(
    id=1,
    defaults={'title': 'Updated title'}
)
```

### Read

```python
# Get all objects
tasks = Task.objects.all()

# Filter
tasks = Task.objects.filter(status='done')
tasks = Task.objects.filter(priority__in=['high', 'urgent'])
tasks = Task.objects.filter(project__name='My Project')

# Exclude
tasks = Task.objects.exclude(status='done')
tasks = Task.objects.exclude(assigned_to=None)

# Get single object
task = Task.objects.get(id=1)
task = Task.objects.get(title='My Task')

# First/last
task = Task.objects.first()
task = Task.objects.last()
task = Task.objects.filter(status='todo').first()

# Count
count = Task.objects.count()
count = Task.objects.filter(priority='high').count()

# Exists
has_tasks = Task.objects.filter(project=project).exists()

# Distinct
users = User.objects.filter(tasks__isnull=False).distinct()

# Values
task_data = Task.objects.values('id', 'title', 'status')
user_emails = User.objects.values_list('email', flat=True)
```

### Update

```python
# Update single object
task = Task.objects.get(id=1)
task.status = 'done'
task.save()

# Update multiple objects
Task.objects.filter(status='todo').update(status='in_progress')

# Update with F expressions
from django.db.models import F
Task.objects.filter(id=1).update(priority=F('priority') + 1)

# Conditional update
tasks = Task.objects.all()
for task in tasks:
    if task.is_overdue:
        task.status = 'overdue'
        task.save()
```

### Delete

```python
# Delete single object
task = Task.objects.get(id=1)
task.delete()

# Delete multiple objects
Task.objects.filter(status='archived').delete()

# Delete all objects
Task.objects.all().delete()
```

---

## Section 2: Field Lookups

### String Lookups

```python
# Exact match
Task.objects.filter(title__exact='My Task')
Task.objects.filter(title='My Task')  # Shortcut

# Case-insensitive exact
Task.objects.filter(title__iexact='my task')

# Contains
Task.objects.filter(title__contains='API')
Task.objects.filter(title__icontains='api')  # Case-insensitive

# Starts/ends with
Task.objects.filter(title__startswith='API')
Task.objects.filter(title__istartswith='api')
Task.objects.filter(title__endswith='docs')
Task.objects.filter(title__iendswith='docs')

# Regex
Task.objects.filter(title__regex=r'^[A-Z]')
Task.objects.filter(title__iregex=r'^[a-z]')
```

### Numeric Lookups

```python
# Greater/Less than
Task.objects.filter(priority__gt=3)  # >
Task.objects.filter(priority__gte=3) # >=
Task.objects.filter(priority__lt=3)  # <
Task.objects.filter(priority__lte=3) # <=

# Range
Task.objects.filter(priority__range=(1, 5))
Task.objects.filter(created_at__range=(start_date, end_date))

# In list
Task.objects.filter(priority__in=[1, 3, 5])
```

### Date/Time Lookups

```python
# Date
from datetime import date, timedelta
today = date.today()
yesterday = today - timedelta(days=1)

Task.objects.filter(created_at__date=today)
Task.objects.filter(created_at__date__gt=yesterday)

# Year, month, day
Task.objects.filter(created_at__year=2026)
Task.objects.filter(created_at__month=1)
Task.objects.filter(created_at__day=15)

# Weekday
Task.objects.filter(created_at__week_day=1)  # Sunday
Task.objects.filter(created_at__week_day__range=(2, 6))

# Time
Task.objects.filter(created_at__hour__gte=9)
Task.objects.filter(created_at__minute=30)

# Null
Task.objects.filter(due_date__isnull=True)

# Date ranges
from django.utils import timezone
now = timezone.now()
Task.objects.filter(
    created_at__gte=now - timedelta(days=7)
)
```

### Boolean Lookups

```python
# True/False
Task.objects.filter(is_active=True)
Task.objects.filter(is_active=False)

# Null
Task.objects.filter(assigned_to__isnull=True)
Task.objects.filter(assigned_to__isnull=False)
```

---

## Section 3: Relationships

### Foreign Key (Many-to-One)

```python
# Forward access
task = Task.objects.get(id=1)
project = task.project  # Gets the project

# Reverse access
project = Project.objects.get(id=1)
tasks = project.tasks.all()  # All tasks in project

# Filter by related field
Task.objects.filter(project__name='My Project')
Task.objects.filter(project__created_by=user)
Task.objects.filter(project__created_by__email='user@example.com')

# Select related (join)
task = Task.objects.select_related('project').get(id=1)
# No extra query when accessing project

# Filter with select_related
tasks = Task.objects.select_related('project', 'assigned_to').all()
```

### Many-to-Many

```python
# Add relationships
project.members.add(user)
project.members.add(user1, user2)
project.members.remove(user)

# Clear relationships
project.members.clear()

# Filter by related
Project.objects.filter(members=user)
Project.objects.filter(members__email='user@example.com')

# Prefetch
projects = Project.objects.prefetch_related('members').all()

# Through model access
class ProjectMembership(models.Model):
    project = models.ForeignKey(Project)
    user = models.ForeignKey(User)
    role = models.CharField(max_length=20)

# Access through model
membership = ProjectMembership.objects.get(project=project, user=user)
role = membership.role
```

### One-to-One

```python
# Access
profile = user.profile  # Gets UserProfile
user = profile.user     # Gets User

# Create
profile = UserProfile.objects.create(user=user, bio='Developer')

# Filter
User.objects.filter(profile__bio__icontains='developer')

# Select related
users = User.objects.select_related('profile').all()
```

---

## Section 4: Aggregations & Annotations

### Aggregations

```python
from django.db.models import Count, Sum, Avg, Min, Max

# Count
total = Task.objects.aggregate(Count('id'))
total = Task.objects.count()

# Sum
total_priority = Task.objects.aggregate(Sum('priority'))

# Average
avg_priority = Task.objects.aggregate(Avg('priority'))

# Min/Max
min_priority = Task.objects.aggregate(Min('priority'))
max_priority = Task.objects.aggregate(Max('priority'))

# Multiple aggregations
stats = Task.objects.aggregate(
    total=Count('id'),
    total_priority=Sum('priority'),
    avg_priority=Avg('priority'),
    max_priority=Max('priority')
)
```

### Annotations

```python
# Count related objects
projects = Project.objects.annotate(
    task_count=Count('tasks')
)

# Sum related field
projects = Project.objects.annotate(
    total_priority=Sum('tasks__priority')
)

# Average related field
projects = Project.objects.annotate(
    avg_priority=Avg('tasks__priority')
)

# Conditional count
from django.db.models import Q
projects = Project.objects.annotate(
    completed_count=Count(
        'tasks',
        filter=Q(tasks__status='done')
    )
)

# Complex annotation
from django.db.models import Case, When, Value, IntegerField

projects = Project.objects.annotate(
    status_score=Case(
        When(tasks__status='done', then=Value(3)),
        When(tasks__status='in_progress', then=Value(2)),
        When(tasks__status='todo', then=Value(1)),
        default=Value(0),
        output_field=IntegerField(),
    )
)
```

---

## Section 5: Query Optimization

### Select Related vs Prefetch Related

```python
# select_related - ForeignKey, OneToOne
tasks = Task.objects.select_related('project', 'assigned_to')

# prefetch_related - ManyToMany, reverse FK
projects = Project.objects.prefetch_related('tasks', 'members')

# Nested prefetch
projects = Project.objects.prefetch_related(
    'tasks__comments'  # Prefetch tasks and their comments
)

# Prefetch with filter
projects = Project.objects.prefetch_related(
    Prefetch(
        'tasks',
        queryset=Task.objects.filter(status='todo'),
        to_attr='pending_tasks'
    )
)
```

### Only & Defer

```python
# Only specific fields
tasks = Task.objects.only('id', 'title', 'status')

# Defer specific fields
tasks = Task.objects.defer('description', 'long_text_field')

# Performance comparison
# Normal: SELECT * FROM tasks_task
# Only:   SELECT id, title, status FROM tasks_task
# Defer:  SELECT all EXCEPT description FROM tasks_task
```

### Values & Values List

```python
# Values as dictionary
tasks = Task.objects.values('id', 'title', 'status')

# Values list
tasks = Task.objects.values_list('id', flat=True)
tasks = Task.objects.values_list('id', 'title', 'status')

# Named values
tasks = Task.objects.values_list(
    'title', 'status',
    named=True
)

# Distinct
tasks = Task.objects.values('project_id').distinct()
```

---

## Section 6: Advanced Queries

### Q Objects (Complex Queries)

```python
from django.db.models import Q

# OR conditions
tasks = Task.objects.filter(
    Q(status='todo') | Q(status='in_progress')
)

# AND conditions with OR
tasks = Task.objects.filter(
    Q(status='todo') | Q(priority='high'),
    project=project
)

# NOT conditions
tasks = Task.objects.filter(
    ~Q(status='done')
)

# Complex nested queries
tasks = Task.objects.filter(
    Q(
        Q(status='todo') | Q(status='in_progress'),
        priority='high'
    ) | Q(assigned_to=user)
)
```

### F Expressions

```python
from django.db.models import F

# Update with current value
Task.objects.filter(id=1).update(priority=F('priority') + 1)

# Compare fields
tasks = Task.objects.filter(priority__gt=F('urgency'))

# Arithmetic
tasks = Task.objects.annotate(
    total=F('priority') + F('urgency')
)

# Avoid race conditions
from django.db import transaction
with transaction.atomic():
    Task.objects.filter(id=1).update(priority=F('priority') + 1)
```

### Subqueries

```python
from django.db.models import Subquery, OuterRef

# Subquery in filter
subquery = Task.objects.filter(project=OuterRef('id'))
projects = Project.objects.annotate(
    has_tasks=Exists(subquery)
)

# Subquery for annotation
task_count = Task.objects.filter(project=OuterRef('id')).values('project_id')
projects = Project.objects.annotate(
    task_count=Subquery(
        task_count.annotate(count=Count('id')).values('count')
    )
)
```

---

## Section 7: Transaction Management

```python
from django.db import transaction

# Atomic block
with transaction.atomic():
    task = Task.objects.create(title='New Task')
    project = Project.objects.get(id=1)
    project.tasks.add(task)

# Transaction decorator
@transaction.atomic
def create_task_with_comments(data):
    task = Task.objects.create(**data)
    Comment.objects.bulk_create([...])
    return task

# Savepoint
with transaction.atomic():
    # Create first object
    obj1 = Model1.objects.create(...)
    
    # Create savepoint
    sid = transaction.savepoint()
    try:
        # Create second object
        obj2 = Model2.objects.create(...)
    except Exception:
        # Rollback to savepoint
        transaction.savepoint_rollback(sid)
    
    # Continue
    obj3 = Model3.objects.create(...)
```

---

## Quick Reference Table

| Operation | Method | Example |
|-----------|--------|---------|
| Create | `create()` | `Task.objects.create(title='Task')` |
| Get all | `all()` | `Task.objects.all()` |
| Filter | `filter()` | `Task.objects.filter(status='done')` |
| Exclude | `exclude()` | `Task.objects.exclude(status='done')` |
| Get one | `get()` | `Task.objects.get(id=1)` |
| First | `first()` | `Task.objects.first()` |
| Count | `count()` | `Task.objects.count()` |
| Exists | `exists()` | `Task.objects.filter(...).exists()` |
| Update | `update()` | `Task.objects.filter(...).update(...)` |
| Delete | `delete()` | `Task.objects.filter(...).delete()` |
| Distinct | `distinct()` | `Task.objects.values('project').distinct()` |
| Order | `order_by()` | `Task.objects.order_by('-created_at')` |
| Select Related | `select_related()` | `Task.objects.select_related('project')` |
| Prefetch Related | `prefetch_related()` | `Project.objects.prefetch_related('tasks')` |
| Values | `values()` | `Task.objects.values('id', 'title')` |
| Values List | `values_list()` | `Task.objects.values_list('id', flat=True)` |
| Aggregate | `aggregate()` | `Task.objects.aggregate(Count('id'))` |
| Annotate | `annotate()` | `Project.objects.annotate(task_count=Count('tasks'))` |
| Q | `Q()` | `Task.objects.filter(Q(status='todo') \| Q(priority='high'))` |
| F | `F()` | `Task.objects.update(priority=F('priority') + 1)` |
| Atomic | `atomic()` | `with transaction.atomic():` |

---

*This concludes Appendix N. Keep this cheat sheet handy for quick reference when working with Django ORM.*
