# Django REST Framework & Next.js 16: Quiz and Test Bank

## Complete Assessment Resource with Answer Keys

---

# Part 1: REST Architecture & HTTP Fundamentals

## Quiz 1.1: Multiple Choice

**1. What does REST stand for?**
- A) Representational State Transfer
- B) Remote Execution System Technology
- C) Reliable Entity State Transmission
- D) Request-Response State Transfer

**2. Which HTTP method is idempotent?**
- A) POST
- B) PUT
- C) PATCH
- D) All of the above

**3. What status code should be returned for a successful POST request?**
- A) 200 OK
- B) 201 Created
- C) 202 Accepted
- D) 204 No Content

**4. Which of the following is NOT a REST constraint?**
- A) Statelessness
- B) Client-Server Separation
- C) Stateful Sessions
- D) Cacheability

**5. What HTTP method should be used to partially update a resource?**
- A) PUT
- B) POST
- C) PATCH
- D) UPDATE

**6. What does status code 401 indicate?**
- A) Resource not found
- B) Unauthorized (Authentication required)
- C) Forbidden (Not enough permissions)
- D) Internal server error

## Quiz 1.2: True/False

**1. GET requests should have a request body.** → False
**2. DELETE requests are idempotent.** → True
**3. 201 Created is a 2xx status code.** → True
**4. PUT requests are safe.** → False
**5. REST APIs should use verbs in URLs.** → False
**6. 429 Too Many Requests is a client error.** → True

## Quiz 1.3: Fill in the Blanks

**1. The HTTP method used to retrieve data is _____ .**
**2. _____ status code indicates "Bad Request."**
**3. REST stands for _____ .**
**4. The HTTP method used to delete a resource is _____ .**
**5. _____ is a lightweight data interchange format used in APIs.**

## Answer Key

### Multiple Choice
1. A
2. B
3. B
4. C
5. C
6. B

### True/False
1. False
2. True
3. True
4. False
5. False
6. True

### Fill in the Blanks
1. GET
2. 400
3. Representational State Transfer
4. DELETE
5. JSON

---

# Part 2: Django 6 Backend Foundations

## Quiz 2.1: Multiple Choice

**1. What command creates a new Django project?**
- A) `django-admin startapp`
- B) `django-admin startproject`
- C) `python manage.py createproject`
- D) `django-admin create`

**2. What is the purpose of Django migrations?**
- A) To version control code
- B) To update the database schema
- C) To deploy the application
- D) To create virtual environments

**3. Which field type is used for many-to-one relationships?**
- A) `ManyToManyField`
- B) `OneToOneField`
- C) `ForeignKey`
- D) `RelationshipField`

**4. How do you create a superuser in Django?**
- A) `python manage.py createsuperuser`
- B) `python manage.py createadmin`
- C) `django-admin createsuperuser`
- D) `python manage.py superuser`

**5. What is the purpose of `USERNAME_FIELD` in a custom User model?**
- A) It specifies the field used for authentication
- B) It defines the primary key
- C) It sets the user's display name
- D) It determines the user's role

**6. Which of the following is NOT a valid model relationship field?**
- A) `ForeignKey`
- B) `OneToOneField`
- C) `ManyToManyField`
- D) `RelatedField`

## Quiz 2.2: True/False

**1. Django projects contain multiple apps.** → True
**2. Migrations are automatically applied when you run `makemigrations`.** → False
**3. `CharField` requires a `max_length` parameter.** → True
**4. The `DateTimeField` with `auto_now_add=True` updates on every save.** → False
**5. A custom User model should inherit from `AbstractUser`.** → True

## Quiz 2.3: Fill in the Blanks

**1. The command to apply migrations is `python manage.py _____`.**
**2. The field used for many-to-many relationships is _____ .**
**3. `_____` is the field used for one-to-one relationships.**
**4. The default primary key field in Django is _____ .**
**5. The file that contains Django project settings is _____ .**

## Answer Key

### Multiple Choice
1. B
2. B
3. C
4. A
5. A
6. D

### True/False
1. True
2. False
3. True
4. False
5. True

### Fill in the Blanks
1. migrate
2. ManyToManyField
3. OneToOneField
4. id (or AutoField)
5. settings.py

---

# Part 3: DRF Serializers

## Quiz 3.1: Multiple Choice

**1. Which serializer type automatically generates fields from a model?**
- A) `Serializer`
- B) `ModelSerializer`
- C) `HyperlinkedModelSerializer`
- D) Both B and C

**2. How do you add field-level validation to a serializer?**
- A) Add a `validate()` method
- B) Add a `validate_<field_name>()` method
- C) Add validation to the model
- D) Use `validators` parameter on the field

**3. What is the purpose of `read_only_fields` in a ModelSerializer?**
- A) They are not included in the response
- B) They cannot be set in requests
- C) They are optional fields
- D) They are automatically generated

**4. Which method is used for object-level validation?**
- A) `validate()` 
- B) `validate_object()`
- C) `is_valid()`
- D) `clean()`

**5. What does `source` parameter do in a serializer field?**
- A) Specifies the field's data type
- B) Maps a field to a different model attribute
- C) Sets the field as read-only
- D) Adds validation to the field

**6. Why would you use different serializers for list and detail views?**
- A) List views need more fields
- B) Detail views need more fields
- C) They use different models
- D) For performance optimization

## Quiz 3.2: True/False

**1. `ModelSerializer` is more verbose than `Serializer`.** → False
**2. `read_only_fields` fields are included in responses but cannot be set in requests.** → True
**3. The `validate()` method is called before individual field validation.** → False
**4. Nested serializers can be used for relationships.** → True
**5. `HyperlinkedModelSerializer` uses primary keys for relationships.** → False

## Quiz 3.3: Fill in the Blanks

**1. The base serializer class in DRF is _____ .**
**2. The `_____` method is used for object-level validation.**
**3. `_____` serializers use hyperlinks for relationships.**
**4. The `_____` parameter maps a field to a different model attribute.**
**5. The `is_valid()` method returns `_____` if validation passes.**

## Answer Key

### Multiple Choice
1. D
2. B
3. B
4. A
5. B
6. D

### True/False
1. False
2. True
3. False
4. True
5. False

### Fill in the Blanks
1. Serializer
2. validate
3. HyperlinkedModelSerializer
4. source
5. True

---

# Part 4: Building API Views

## Quiz 4.1: Multiple Choice

**1. What decorator is used for function-based DRF views?**
- A) `@api_view`
- B) `@view`
- C) `@rest_view`
- D) `@api`

**2. What is the correct response for a successful DELETE request?**
- A) 200 OK
- B) 201 Created
- C) 204 No Content
- D) 202 Accepted

**3. Which class is the base for class-based DRF views?**
- A) `View`
- B) `APIView`
- C) `GenericView`
- D) `BaseView`

**4. How do you handle a `DoesNotExist` exception in a view?**
- A) Let it raise a 500 error
- B) Return 404 Not Found
- C) Return 400 Bad Request
- D) Return 403 Forbidden

**5. What does the `Response` class do?**
- A) Renders templates
- B) Returns HTTP responses with proper content type
- C) Redirects to another URL
- D) Validates request data

**6. Which status code indicates a successful POST request?**
- A) 200 OK
- B) 201 Created
- C) 202 Accepted
- D) 204 No Content

## Quiz 4.2: True/False

**1. Function-based views can only handle one HTTP method.** → False
**2. `APIView` provides more structure than `@api_view`.** → True
**3. `Response` automatically handles JSON serialization.** → True
**4. The `get_object()` method is available in `APIView`.** → False
**5. 404 Not Found should be returned when a resource doesn't exist.** → True

## Quiz 4.3: Fill in the Blanks

**1. The decorator for function-based DRF views is _____ .**
**2. The base class for class-based DRF views is _____ .**
**3. The status code for "Not Found" is _____ .**
**4. `Response` takes _____ as its first argument.**
**5. The `get_object()` method is available in _____ views.**

## Answer Key

### Multiple Choice
1. A
2. C
3. B
4. B
5. B
6. B

### True/False
1. False
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. @api_view
2. APIView
3. 404
4. data
5. Generic (or class-based)

---

# Part 5: Next.js 16 Foundations

## Quiz 5.1: Multiple Choice

**1. What directive makes a component a Client Component?**
- A) `'use client'`
- B) `'use server'`
- C) `'use react'`
- D) `'use next'`

**2. Which file defines the root layout in Next.js App Router?**
- A) `app/page.tsx`
- B) `app/layout.tsx`
- C) `app/root.tsx`
- D) `app/index.tsx`

**3. What is the purpose of `loading.tsx`?**
- A) To show a loading state while pages load
- B) To handle errors
- C) To configure the app
- D) To define metadata

**4. Which is true about Server Components?**
- A) They can use hooks
- B) They can use async/await
- C) They run in the browser
- D) They can use event handlers

**5. What is the default component type in Next.js App Router?**
- A) Client Component
- B) Server Component
- C) Hybrid Component
- D) Static Component

**6. What file in Next.js handles 404 errors?**
- A) `error.tsx`
- B) `not-found.tsx`
- C) `404.tsx`
- D) `page.tsx`

## Quiz 5.2: True/False

**1. Server Components can use React hooks.** → False
**2. Route groups affect the URL path.** → False
**3. `page.tsx` defines a route in the App Router.** → True
**4. Client Components can use browser APIs.** → True
**5. `globals.css` is the default styles file in Next.js.** → True

## Quiz 5.3: Fill in the Blanks

**1. The directive for Client Components is _____ .**
**2. The root layout file is `app/_____`.**
**3. Dynamic routes use _____ in the folder name.**
**4. The `_____` file shows a loading state while pages load.**
**5. Next.js uses the App Router with the `app` directory by _____ .**

## Answer Key

### Multiple Choice
1. A
2. B
3. A
4. B
5. B
6. B

### True/False
1. False
2. False
3. True
4. True
5. True

### Fill in the Blanks
1. 'use client'
2. layout.tsx
3. brackets []
4. loading.tsx
5. default

---

# Part 6: Connecting Next.js to DRF

## Quiz 6.1: Multiple Choice

**1. What method would you use for server-side data fetching in Next.js?**
- A) `useEffect` with `fetch`
- B) `getServerSideProps`
- C) Async/await in Server Component
- D) `useState` with `fetch`

**2. Why is server-side fetching preferred for initial page load?**
- A) It's faster
- B) It's simpler
- C) It provides better SEO
- D) All of the above

**3. What is the purpose of an API client abstraction?**
- A) To make code more complex
- B) To centralize API calls and error handling
- C) To bypass CORS
- D) To improve performance

**4. How do you handle loading states in React?**
- A) Use a boolean state variable
- B) Use `useEffect`
- C) Use `useMemo`
- D) Use `useCallback`

**5. What does `router.push()` do?**
- A) Navigates to a new page
- B) Refreshes the current page
- C) Returns to the previous page
- D) Replaces the current URL

**6. What is the purpose of `isValid()` in a form?**
- A) To check if the form is rendered
- B) To validate form data
- C) To submit the form
- D) To reset the form

## Quiz 6.2: True/False

**1. Server Components can use `fetch`.** → True
**2. Client-side fetching is always slower than server-side.** → False
**3. `useEffect` is the only way to fetch data in Client Components.** → False
**4. API errors should be displayed to users.** → True
**5. Forms in Next.js can use Server Actions.** → True

## Quiz 6.3: Fill in the Blanks

**1. The hook for navigation in Next.js is `use_____`.**
**2. The `fetch` API returns a _____ .**
**3. `_____` is used for error handling in API calls.**
**4. The hook for state in React is `use_____`.**
**5. Loading states use _____ and `isLoading`.**

## Answer Key

### Multiple Choice
1. C
2. D
3. B
4. A
5. A
6. B

### True/False
1. True
2. False
3. False
4. True
5. True

### Fill in the Blanks
1. Router
2. Promise
3. try/catch
4. useState
5. useState

---

# Part 7: CRUD Operations Across the Stack

## Quiz 7.1: Multiple Choice

**1. What is the correct URL for updating a task with ID 1?**
- A) `POST /api/tasks/1/`
- B) `PUT /api/tasks/1/`
- C) `PATCH /api/tasks/1/`
- D) Both B and C

**2. What status code indicates successful deletion?**
- A) 200 OK
- B) 201 Created
- C) 204 No Content
- D) 202 Accepted

**3. What is the purpose of optimistic updates?**
- A) To make the app faster
- B) To improve user experience
- C) To reduce server load
- D) To simplify code

**4. Which component is used for user feedback on actions?**
- A) Modal
- B) Toast notification
- C) Alert
- D) Both A and B

**5. What does a confirmation modal prevent?**
- A) Accidental form submission
- B) Accidental deletion
- C) Accidental navigation
- D) All of the above

**6. How do you handle validation errors from the API?**
- A) Display a generic error message
- B) Display field-specific errors
- C) Ignore them
- D) Log them to console

## Quiz 7.2: True/False

**1. DELETE requests should return 204 No Content.** → True
**2. Toast notifications are modal dialogs.** → False
**3. Optimistic updates update the UI after server confirmation.** → False
**4. `router.refresh()` revalidates the current page.** → True
**5. Validation errors should always be displayed.** → True

## Quiz 7.3: Fill in the Blanks

**1. The HTTP method for deleting a resource is _____ .**
**2. `_____` update the UI immediately while the server processes the request.**
**3. The status code for a successful POST is _____ .**
**4. `_____` notifications appear at the top or bottom of the screen.**
**5. A _____ modal requires explicit user confirmation.**

## Answer Key

### Multiple Choice
1. D
2. C
3. B
4. D
5. B
6. B

### True/False
1. True
2. False
3. False
4. True
5. True

### Fill in the Blanks
1. DELETE
2. Optimistic
3. 201
4. Toast
5. confirmation

---

# Part 8: Generic Views, ViewSets & Routers

## Quiz 8.1: Multiple Choice

**1. Which class automatically handles CRUD operations?**
- A) `viewsets.ViewSet`
- B) `viewsets.ModelViewSet`
- C) `viewsets.GenericViewSet`
- D) `viewsets.ReadOnlyModelViewSet`

**2. How do you add a custom action to a ViewSet?**
- A) Add a method with `@action` decorator
- B) Override `get_queryset()`
- C) Use `extra_actions` attribute
- D) Add a URL pattern manually

**3. What does the router do?**
- A) Handles database connections
- B) Generates URL patterns for ViewSets
- C) Configures CORS
- D) Manages authentication

**4. Which method should be overridden to set the user on a created object?**
- A) `create()`
- B) `perform_create()`
- C) `save()`
- D) `serialize()`

**5. What is the purpose of `get_serializer_class()`?**
- A) To return different serializers for different actions
- B) To create a new serializer instance
- C) To validate serializer data
- D) To save serializer data

**6. Which of the following is NOT a built-in ViewSet action?**
- A) `list()`
- B) `create()`
- C) `update()`
- D) `stats()`

## Quiz 8.2: True/False

**1. `ModelViewSet` provides CRUD operations.** → True
**2. The `@action` decorator creates custom endpoints.** → True
**3. Routers automatically create all URLs for a ViewSet.** → True
**4. `perform_create()` is called before the serializer saves.** → False
**5. `ReadOnlyModelViewSet` provides update operations.** → False

## Quiz 8.3: Fill in the Blanks

**1. The class that provides CRUD operations is `_____`.**
**2. The `_____` decorator adds custom actions to ViewSets.**
**3. The router class in DRF is `_____`.**
**4. `perform_create()` is called after _____ validation.**
**5. `get_serializer_class()` returns the _____ class for the action.**

## Answer Key

### Multiple Choice
1. B
2. A
3. B
4. B
5. A
6. D

### True/False
1. True
2. True
3. True
4. False
5. False

### Fill in the Blanks
1. ModelViewSet
2. @action
3. DefaultRouter
4. serializer
5. serializer

---

# Part 9: Advanced Querying

## Quiz 9.1: Multiple Choice

**1. Which package is used for advanced filtering in DRF?**
- A) `django-filter`
- B) `django-query`
- C) `django-search`
- D) `django-advanced`

**2. What is the purpose of `search_fields`?**
- A) To specify which fields can be searched
- B) To specify which fields can be filtered
- C) To specify which fields can be ordered
- D) To specify which fields are returned

**3. How do you create a custom filter method?**
- A) Add `method` parameter to a filter field
- B) Override `get_queryset()`
- C) Use `filter_methods` attribute
- D) Add a `filter()` method to the view

**4. What does `icontains` lookup do?**
- A) Exact match
- B) Contains (case-sensitive)
- C) Contains (case-insensitive)
- D) Starts with

**5. Which query parameter is used for ordering?**
- A) `order`
- B) `sort`
- C) `ordering`
- D) `order_by`

**6. What does `DjangoFilterBackend` do?**
- A) Implements filtering
- B) Implements search
- C) Implements ordering
- D) Implements pagination

## Quiz 9.2: True/False

**1. `django-filter` is built into Django.** → False
**2. `search_fields` works with `SearchFilter`.** → True
**3. Custom filter methods must return a QuerySet.** → True
**4. Multiple filters can be combined using `&` and `|`.** → True
**5. `ordering_fields` limits the fields that can be ordered by.** → True

## Quiz 9.3: Fill in the Blanks

**1. The package for advanced filtering is _____ .**
**2. `_____` is used for case-insensitive contains lookups.**
**3. The `_____` backend enables ordering in DRF.**
**4. `_____` parameters are used for filtering in URLs.**
**5. The `Q` object is used for _____ queries.**

## Answer Key

### Multiple Choice
1. A
2. A
3. A
4. C
5. C
6. A

### True/False
1. False
2. True
3. True
4. True
5. True

### Fill in the Blanks
1. django-filter
2. icontains
3. OrderingFilter
4. Query
5. complex

---

# Part 10: Pagination

## Quiz 10.1: Multiple Choice

**1. What is the default page size in DRF?**
- A) 10
- B) 20
- C) 50
- D) 100

**2. How do you allow clients to set page size?**
- A) `page_size_query_param`
- B) `page_size_parameter`
- C) `size_query_param`
- D) `limit_query_param`

**3. What is the purpose of cursor pagination?**
- A) To navigate to specific pages
- B) To prevent duplicate items in infinite scrolling
- C) To set page size
- D) To optimize performance

**4. Which pagination style uses `limit` and `offset`?**
- A) PageNumberPagination
- B) LimitOffsetPagination
- C) CursorPagination
- D) PageSizePagination

**5. What information should a paginated response include?**
- A) Results only
- B) Results and count
- C) Results, count, and navigation links
- D) Results and next page URL

**6. How do you implement pagination in DRF?**
- A) Add `pagination_class` to settings
- B) Add `pagination_class` to views
- C) Both A and B
- D) None of the above

## Quiz 10.2: True/False

**1. PageNumberPagination is the default pagination class.** → True
**2. `max_page_size` limits the maximum page size.** → True
**3. Cursor pagination is best for infinite scrolling.** → True
**4. The `page` parameter is used for LimitOffsetPagination.** → False
**5. Pagination metadata is automatically included in responses.** → True

## Quiz 10.3: Fill in the Blanks

**1. The default pagination class in DRF is _____ .**
**2. The parameter for page size is `_____`.**
**3. `_____` pagination is best for infinite scrolling.**
**4. The `_____` parameter is used for LimitOffsetPagination.**
**5. `max_page_size` sets the _____ page size.**

## Answer Key

### Multiple Choice
1. B
2. A
3. B
4. B
5. C
6. C

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. PageNumberPagination
2. page_size_query_param
3. Cursor
4. limit / offset
5. maximum

---

# Part 11: Next.js Routing & Navigation

## Quiz 11.1: Multiple Choice

**1. What type of route is `[id]/page.tsx`?**
- A) Static route
- B) Dynamic route
- C) Catch-all route
- D) Route group

**2. How do you create a route that doesn't affect the URL?**
- A) Use `[param]`
- B) Use `(group)`
- C) Use `[...slug]`
- D) Use `@folder`

**3. What file defines a route's layout?**
- A) `layout.tsx`
- B) `page.tsx`
- C) `template.tsx`
- D) `root.tsx`

**4. What is the purpose of `error.tsx`?**
- A) To show errors in development
- B) To catch errors in a route segment
- C) To display 404 pages
- D) To log errors

**5. How do you implement nested layouts?**
- A) Create nested `layout.tsx` files
- B) Use `template.tsx`
- C) Use `route.ts`
- D) Use `not-found.tsx`

**6. What does `usePathname()` do?**
- A) Gets the current URL pathname
- B) Navigates to a new page
- C) Returns to the previous page
- D) Sets the page title

## Quiz 11.2: True/False

**1. Route groups affect the URL path.** → False
**2. Dynamic routes use `[param]` in the folder name.** → True
**3. `loading.tsx` shows during navigation.** → True
**4. `not-found.tsx` handles 404 errors for a route.** → True
**5. `useRouter` is available in Server Components.** → False

## Quiz 11.3: Fill in the Blanks

**1. The hook for navigation in Next.js is `use_____`.**
**2. Dynamic route parameters are accessed through `_____`.**
**3. The `_____` function is used for programmatic navigation.**
**4. Route groups use _____ in the folder name.**
**5. The `_____` file defines the layout for a route.**

## Answer Key

### Multiple Choice
1. B
2. B
3. A
4. B
5. A
6. A

### True/False
1. False
2. True
3. True
4. True
5. False

### Fill in the Blanks
1. Router
2. params
3. router.push()
4. parentheses ()
5. layout.tsx

---

# Part 12: Frontend Data Architecture

## Quiz 12.1: Multiple Choice

**1. What is the purpose of React Query?**
- A) State management
- B) Data fetching and caching
- C) UI rendering
- D) Routing

**2. What does `staleTime` control?**
- A) How long data is considered fresh
- B) How long data is cached
- C) How often data is refetched
- D) How long data persists

**3. What is the purpose of `invalidateQueries()`?**
- A) To delete cached data
- B) To mark queries as stale
- C) To fetch new data
- D) To cancel queries

**4. How do you implement optimistic updates?**
- A) Use `useOptimistic`
- B) Update the cache before the mutation succeeds
- C) Use `useEffect`
- D) Use `useState`

**5. What is the purpose of `QueryClient`?**
- A) To create new queries
- B) To manage the cache and configuration
- C) To render components
- D) To handle errors

**6. What does `gcTime` control?**
- A) How long data is considered fresh
- B) How long inactive queries are kept
- C) How often queries are refetched
- D) How long errors are cached

## Quiz 12.2: True/False

**1. React Query uses a built-in cache.** → True
**2. `staleTime` default is 0 seconds.** → True
**3. Optimistic updates improve user experience.** → True
**4. `invalidateQueries()` triggers a refetch.** → True
**5. React Query replaces all state management.** → False

## Quiz 12.3: Fill in the Blanks

**1. React Query is used for _____ and _____ data.**
**2. `_____` controls how long data is considered fresh.**
**3. `_____` invalidates cached queries.**
**4. Optimistic updates _____ the UI before the server responds.**
**5. `QueryClient` manages the _____ and configuration.**

## Answer Key

### Multiple Choice
1. B
2. A
3. B
4. B
5. B
6. B

### True/False
1. True
2. True
3. True
4. True
5. False

### Fill in the Blanks
1. fetching, caching
2. staleTime
3. invalidateQueries()
4. update
5. cache

---

# Part 13: Searchable Data Interfaces

## Quiz 13.1: Multiple Choice

**1. What are the benefits of URL-based state?**
- A) Shareable links
- B) Bookmarkable views
- C) Browser navigation works
- D) All of the above

**2. How do you implement debounced search?**
- A) Use `setTimeout` in `onChange`
- B) Use `useEffect` with debounce
- C) Both A and B
- D) None of the above

**3. What is the purpose of `useSearchParams()`?**
- A) To get URL query parameters
- B) To navigate to a new page
- C) To set page title
- D) To get route parameters

**4. How do you handle sorting in a data table?**
- A) Send `sort` parameter to API
- B) Sort client-side
- C) Both A and B
- D) None of the above

**5. What information should a paginated response include?**
- A) Results only
- B) Results and count
- C) Results, count, and navigation links
- D) Results and next page URL

**6. How do you combine filters in a search interface?**
- A) Use multiple query parameters
- B) Use a single query parameter
- C) Use POST request
- D) Use WebSockets

## Quiz 13.2: True/False

**1. URL state is shareable.** → True
**2. Debouncing reduces unnecessary API calls.** → True
**3. `useSearchParams()` is available in Server Components.** → False
**4. Sorting can be handled on the server or client.** → True
**5. Pagination should only be handled on the client.** → False

## Quiz 13.3: Fill in the Blanks

**1. URL-based state enables _____ links.**
**2. Debouncing delays _____ calls.**
**3. `useSearchParams()` gets _____ parameters.**
**4. Sorting sends a _____ parameter to the API.**
**5. Pagination reduces _____ size.**

## Answer Key

### Multiple Choice
1. D
2. C
3. A
4. C
5. C
6. A

### True/False
1. True
2. True
3. False
4. True
5. False

### Fill in the Blanks
1. shareable
2. API
3. query
4. sort
5. response

---

# Part 14: Authentication Architecture

## Quiz 14.1: Multiple Choice

**1. What is the difference between authentication and authorization?**
- A) Authentication is about identity; authorization is about permissions
- B) Authentication is about permissions; authorization is about identity
- C) They are the same thing
- D) Authentication is for users; authorization is for systems

**2. What are the three parts of a JWT?**
- A) Header, Body, Signature
- B) Header, Payload, Signature
- C) Header, Body, Footer
- D) Header, Data, Signature

**3. What is the purpose of a refresh token?**
- A) To authenticate the user
- B) To get a new access token
- C) To log out the user
- D) To encrypt data

**4. How long should an access token typically live?**
- A) Minutes
- B) Hours
- C) Days
- D) Weeks

**5. What is the purpose of token rotation?**
- A) To improve security
- B) To reduce token size
- C) To speed up authentication
- D) To simplify the API

**6. What is the endpoint for obtaining a JWT token pair?**
- A) `/api/v1/token/`
- B) `/api/v1/token/refresh/`
- C) `/api/v1/token/verify/`
- D) `/api/v1/users/login/`

## Quiz 14.2: True/False

**1. JWT stands for JavaScript Web Token.** → False
**2. Refresh tokens are short-lived.** → False
**3. Token rotation improves security.** → True
**4. JWT tokens are signed.** → True
**5. Authentication verifies identity.** → True

## Quiz 14.3: Fill in the Blanks

**1. The three parts of a JWT are _____ , _____ , and _____ .**
**2. A _____ token is used to get a new access token.**
**3. Token rotation _____ the refresh token on each use.**
**4. JWT tokens are _____ to prevent tampering.**
**5. The endpoint for obtaining a token is _____ .**

## Answer Key

### Multiple Choice
1. A
2. B
3. B
4. A
5. A
6. A

### True/False
1. False
2. False
3. True
4. True
5. True

### Fill in the Blanks
1. Header, Payload, Signature
2. refresh
3. rotates
4. signed
5. /api/v1/token/

---

# Part 15: JWT with SimpleJWT

## Quiz 15.1: Multiple Choice

**1. How should access tokens be stored on the client?**
- A) localStorage
- B) sessionStorage
- C) HTTP-only cookies
- D) Any of the above

**2. What is the purpose of an API interceptor?**
- A) To add authentication headers
- B) To handle token refresh
- C) To handle errors
- D) All of the above

**3. How do you protect routes in Next.js?**
- A) Use middleware
- B) Use ProtectedRoute component
- C) Both A and B
- D) None of the above

**4. What happens when an access token expires?**
- A) The user is logged out
- B) The refresh token is used to get a new access token
- C) The user must re-authenticate
- D) The token is automatically renewed

**5. What is the purpose of `useAuth`?**
- A) To provide authentication state to components
- B) To handle login and logout
- C) Both A and B
- D) None of the above

**6. Which middleware protects routes in Next.js?**
- A) `middleware.ts`
- B) `auth.ts`
- C) `route.ts`
- D) `guard.ts`

## Quiz 15.2: True/False

**1. Access tokens should be stored in localStorage for security.** → False
**2. Refresh tokens are used to get new access tokens.** → True
**3. API interceptors automatically add authentication headers.** → True
**4. ProtectedRoute component is used for route protection.** → True
**5. middleware.ts runs on the client.** → False

## Quiz 15.3: Fill in the Blanks

**1. The `_____` interceptor adds authentication headers.**
**2. Refresh tokens are stored in _____ cookies for security.**
**3. `useAuth` provides _____ state to components.**
**4. The `_____` middleware protects routes in Next.js.**
**5. `ProtectedRoute` is a _____ component.**

## Answer Key

### Multiple Choice
1. C
2. D
3. C
4. B
5. C
6. A

### True/False
1. False
2. True
3. True
4. True
5. False

### Fill in the Blanks
1. request
2. HTTP-only
3. authentication
4. middleware
5. client

---

# Part 16: DRF Permissions

## Quiz 16.1: Multiple Choice

**1. What method checks view-level permissions?**
- A) `has_permission()`
- B) `has_object_permission()`
- C) `check_permissions()`
- D) `validate_permissions()`

**2. What method checks object-level permissions?**
- A) `has_permission()`
- B) `has_object_permission()`
- C) `check_permissions()`
- D) `validate_permissions()`

**3. Which permission class allows any authenticated user?**
- A) `AllowAny`
- B) `IsAuthenticated`
- C) `IsAdminUser`
- D) `IsAuthenticatedOrReadOnly`

**4. How do you create a custom permission?**
- A) Inherit from `BasePermission`
- B) Inherit from `Permission`
- C) Inherit from `CustomPermission`
- D) Inherit from `APIView`

**5. What is the purpose of `get_permissions()` in a ViewSet?**
- A) To set permissions for different actions
- B) To get user permissions
- C) To validate permissions
- D) To check object permissions

**6. Which permission class allows read-only access for unauthenticated users?**
- A) `AllowAny`
- B) `IsAuthenticated`
- C) `IsAdminUser`
- D) `IsAuthenticatedOrReadOnly`

## Quiz 16.2: True/False

**1. `has_permission()` is called before `has_object_permission()`.** → True
**2. Custom permissions must override `has_permission()`.** → False
**3. Object-level permissions check specific objects.** → True
**4. `IsAuthenticated` allows all users.** → False
**5. Permissions are checked on every request.** → True

## Quiz 16.3: Fill in the Blanks

**1. The method for view-level permissions is `_____`.**
**2. The method for object-level permissions is `_____`.**
**3. `BasePermission` is used for _____ permissions.**
**4. `IsAuthenticated` requires a _____ user.**
**5. `get_permissions()` returns a _____ of permission classes.**

## Answer Key

### Multiple Choice
1. A
2. B
3. B
4. A
5. A
6. D

### True/False
1. True
2. False
3. True
4. False
5. True

### Fill in the Blanks
1. has_permission()
2. has_object_permission()
3. custom
4. authenticated
5. list

---

# Part 17: Role-Based Access Control

## Quiz 17.1: Multiple Choice

**1. What does RBAC stand for?**
- A) Role-Based Access Control
- B) Resource-Based Access Control
- C) Rule-Based Access Control
- D) Request-Based Access Control

**2. Which role typically has the most permissions?**
- A) Admin
- B) Manager
- C) Member
- D) Viewer

**3. What is the purpose of role methods in the User model?**
- A) To check user roles
- B) To set user roles
- C) Both A and B
- D) None of the above

**4. How do you implement role-based UI in React?**
- A) Use RoleGuard component
- B) Use conditional rendering
- C) Both A and B
- D) None of the above

**5. What is the purpose of `has_permission()` in the User model?**
- A) To check specific permissions
- B) To check user roles
- C) Both A and B
- D) None of the above

**6. Which component provides role-based access to children?**
- A) `RoleGuard`
- B) `AuthGuard`
- C) `PermissionGuard`
- D) `RouteGuard`

## Quiz 17.2: True/False

**1. RBAC stands for Role-Based Access Control.** → True
**2. Admins have the most permissions.** → True
**3. Role methods should be in the view, not the model.** → False
**4. `RoleGuard` is a client component.** → True
**5. Permissions can be checked in both frontend and backend.** → True

## Quiz 17.3: Fill in the Blanks

**1. RBAC stands for _____ .**
**2. The _____ role has the most permissions.**
**3. `has_permission()` checks _____ permissions.**
**4. `RoleGuard` provides _____ access control.**
**5. Permissions should be checked on the _____ for security.**

## Answer Key

### Multiple Choice
1. A
2. A
3. C
4. C
5. A
6. A

### True/False
1. True
2. True
3. False
4. True
5. True

### Fill in the Blanks
1. Role-Based Access Control
2. Admin
3. specific
4. role-based
5. backend

---

# Part 18: Next.js Authentication

## Quiz 18.1: Multiple Choice

**1. What is the purpose of `getServerUser()`?**
- A) To get user data on the server
- B) To get user data on the client
- C) To log in a user
- D) To log out a user

**2. What does `requireAuth()` do?**
- A) Redirects to login if not authenticated
- B) Returns user data
- C) Both A and B
- D) None of the above

**3. Where does `getServerUser()` run?**
- A) Server
- B) Client
- C) Both server and client
- D) Middleware

**4. What is the purpose of `jwtDecode`?**
- A) To decode JWT tokens
- B) To encode JWT tokens
- C) To verify JWT tokens
- D) To sign JWT tokens

**5. How do you access cookies in Server Components?**
- A) `cookies()`
- B) `request.cookies`
- C) `document.cookie`
- D) `getCookie()`

**6. What does `redirect()` do in a Server Component?**
- A) Redirects to the specified URL
- B) Returns a redirect response
- C) Both A and B
- D) None of the above

## Quiz 18.2: True/False

**1. Server Components can access cookies.** → True
**2. `requireAuth()` is a client-side function.** → False
**3. `jwtDecode` is used to verify token validity.** → True
**4. `redirect()` is available in Server Components.** → True
**5. `getServerUser()` runs on the client.** → False

## Quiz 18.3: Fill in the Blanks

**1. `getServerUser()` returns _____ data.**
**2. `requireAuth()` redirects to _____ if not authenticated.**
**3. `_____` is used to decode JWT tokens.**
**4. The `cookies()` function is available in _____ Components.**
**5. `redirect()` is a _____ function.**

## Answer Key

### Multiple Choice
1. A
2. C
3. A
4. A
5. A
6. C

### True/False
1. True
2. False
3. True
4. True
5. False

### Fill in the Blanks
1. user
2. login
3. jwtDecode
4. Server
5. server

---

# Part 19: Next.js Request Interception

## Quiz 19.1: Multiple Choice

**1. What is the purpose of an API interceptor?**
- A) To add authentication headers
- B) To handle token refresh
- C) To handle errors
- D) All of the above

**2. When should a token be refreshed?**
- A) When it expires
- B) On every request
- C) On login
- D) On logout

**3. What happens when a 401 response is received?**
- A) The user is logged out
- B) The token is refreshed and the request is retried
- C) The request fails
- D) The user is redirected

**4. What is the purpose of `originalRequest._retry`?**
- A) To prevent infinite refresh loops
- B) To track retry attempts
- C) Both A and B
- D) None of the above

**5. How does the interceptor handle refresh failures?**
- A) Redirects to login
- B) Clears tokens
- C) Both A and B
- D) None of the above

**6. What is the purpose of the request interceptor?**
- A) To add authentication headers
- B) To handle token refresh
- C) Both A and B
- D) None of the above

## Quiz 19.2: True/False

**1. Interceptors run on every request.** → True
**2. Token refresh is automatic in the interceptor.** → True
**3. `_retry` prevents infinite refresh loops.** → True
**4. 401 responses always require user re-authentication.** → False
**5. Interceptors can handle both requests and responses.** → True

## Quiz 19.3: Fill in the Blanks

**1. The `_____` interceptor adds authentication headers.**
**2. Token refresh is triggered by a _____ response.**
**3. `_retry` prevents _____ refresh loops.**
**4. Refresh failures redirect to _____ .**
**5. Interceptors run on every _____ .**

## Answer Key

### Multiple Choice
1. D
2. A
3. B
4. C
5. C
6. A

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. request
2. 401
3. infinite
4. login
5. request

---

# Part 20: API Security

## Quiz 20.1: Multiple Choice

**1. What is the purpose of rate limiting?**
- A) To prevent abuse
- B) To improve performance
- C) Both A and B
- D) None of the above

**2. What is the purpose of CORS?**
- A) To allow cross-origin requests
- B) To block cross-origin requests
- C) Both A and B
- D) None of the above

**3. Which security header prevents clickjacking?**
- A) `X-Frame-Options`
- B) `X-Content-Type-Options`
- C) `X-XSS-Protection`
- D) `Content-Security-Policy`

**4. What does `nosniff` header prevent?**
- A) MIME type sniffing
- B) Clickjacking
- C) XSS attacks
- D) CORS attacks

**5. What is the purpose of `Content-Security-Policy`?**
- A) To restrict resources that can be loaded
- B) To prevent XSS attacks
- C) Both A and B
- D) None of the above

**6. How do you implement rate limiting in Django?**
- A) `django-ratelimit`
- B) `django-throttle`
- C) `django-limit`
- D) `django-restrict`

## Quiz 20.2: True/False

**1. Rate limiting prevents brute force attacks.** → True
**2. CORS should be disabled in production.** → False
**3. Security headers are set in the middleware.** → True
**4. `X-Frame-Options` prevents XSS attacks.** → False
**5. `Content-Security-Policy` restricts resource loading.** → True

## Quiz 20.3: Fill in the Blanks

**1. Rate limiting prevents _____ attacks.**
**2. CORS stands for _____ .**
**3. `X-Frame-Options` prevents _____ .**
**4. `nosniff` prevents _____ type sniffing.**
**5. `Content-Security-Policy` restricts _____ sources.**

## Answer Key

### Multiple Choice
1. C
2. C
3. A
4. A
5. C
6. A

### True/False
1. True
2. False
3. True
4. False
5. True

### Fill in the Blanks
1. brute force
2. Cross-Origin Resource Sharing
3. clickjacking
4. MIME
5. resource

---

# Part 21: Django ORM Performance

## Quiz 21.1: Multiple Choice

**1. What is the N+1 query problem?**
- A) One query for the list, N queries for related data
- B) N+1 queries for a single object
- C) A query that returns N+1 rows
- D) A query that takes N+1 seconds

**2. How do you solve the N+1 query problem?**
- A) `select_related` and `prefetch_related`
- B) `only` and `defer`
- C) `values` and `values_list`
- D) `filter` and `exclude`

**3. What does `select_related` do?**
- A) Performs a JOIN to fetch related data
- B) Performs a separate query for related data
- C) Selects only specific fields
- D) Defers loading of fields

**4. What does `prefetch_related` do?**
- A) Performs a separate query for related data
- B) Performs a JOIN to fetch related data
- C) Selects only specific fields
- D) Defers loading of fields

**5. What is the purpose of database indexes?**
- A) To speed up queries
- B) To ensure data integrity
- C) Both A and B
- D) None of the above

**6. What does `only()` do?**
- A) Selects specific fields
- B) Defers loading of fields
- C) Performs a JOIN
- D) Adds an index

## Quiz 21.2: True/False

**1. `select_related` performs a JOIN.** → True
**2. `prefetch_related` performs a separate query.** → True
**3. Indexes speed up write operations.** → False
**4. `only()` reduces the data loaded from the database.** → True
**5. `defer()` defers loading of fields.** → True

## Quiz 21.3: Fill in the Blanks

**1. The N+1 query problem occurs with _____ data.**
**2. `select_related` performs a _____ .**
**3. `prefetch_related` performs a _____ query.**
**4. Indexes speed up _____ operations.**
**5. `only()` selects _____ fields.**

## Answer Key

### Multiple Choice
1. A
2. A
3. A
4. A
5. A
6. A

### True/False
1. True
2. True
3. False
4. True
5. True

### Fill in the Blanks
1. related
2. JOIN
3. separate
4. read
5. specific

---

# Part 22: Redis Caching

## Quiz 22.1: Multiple Choice

**1. What is Redis?**
- A) An in-memory data store
- B) A relational database
- C) A file system
- D) A message queue

**2. What is the purpose of caching?**
- A) To speed up responses
- B) To reduce database load
- C) Both A and B
- D) None of the above

**3. What is the purpose of TTL in caching?**
- A) To automatically expire cached data
- B) To set cache size
- C) To optimize cache performance
- D) To invalidate cache

**4. What is cache invalidation?**
- A) Removing stale cache entries
- B) Adding new cache entries
- C) Updating cache entries
- D) Checking cache entries

**5. Which caching strategy is used in DRF?**
- A) View caching
- B) Template caching
- C) Query caching
- D) All of the above

**6. What is the purpose of `cache_page` decorator?**
- A) To cache the entire view response
- B) To cache a specific part of the view
- C) To cache database queries
- D) To cache templates

## Quiz 22.2: True/False

**1. Redis is an in-memory data store.** → True
**2. Caching reduces database load.** → True
**3. TTL stands for Time To Live.** → True
**4. Cache invalidation is optional.** → False
**5. `cache_page` caches the entire view.** → True

## Quiz 22.3: Fill in the Blanks

**1. Redis is an _____ data store.**
**2. Caching _____ response times.**
**3. TTL stands for _____ .**
**4. Cache _____ removes stale entries.**
**5. `cache_page` caches the entire _____ .**

## Answer Key

### Multiple Choice
1. A
2. C
3. A
4. A
5. D
6. A

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. in-memory
2. speeds up
3. Time To Live
4. invalidation
5. view

---

# Part 23: API Performance

## Quiz 23.1: Multiple Choice

**1. What is the purpose of response compression?**
- A) To reduce response size
- B) To speed up response time
- C) Both A and B
- D) None of the above

**2. What is the purpose of connection pooling?**
- A) To reuse database connections
- B) To create new database connections
- C) To close database connections
- D) To optimize database performance

**3. What does `CONN_MAX_AGE` control?**
- A) How long database connections are kept alive
- B) How many connections are allowed
- C) How long queries can run
- D) How long transactions can run

**4. How do you optimize serializers for performance?**
- A) Use different serializers for list and detail views
- B) Use `only()` and `defer()`
- C) Both A and B
- D) None of the above

**5. What is the purpose of `GZipMiddleware`?**
- A) To compress response content
- B) To decompress request content
- C) Both A and B
- D) None of the above

**6. What is the purpose of `preload_app` in Gunicorn?**
- A) To preload application code before forking
- B) To preload database connections
- C) To preload cache data
- D) To preload templates

## Quiz 23.2: True/False

**1. Response compression reduces bandwidth usage.** → True
**2. Connection pooling reduces connection overhead.** → True
**3. `CONN_MAX_AGE` should be high in production.** → True
**4. List views need more fields than detail views.** → False
**5. `GZipMiddleware` compresses responses.** → True

## Quiz 23.3: Fill in the Blanks

**1. Response compression _____ response size.**
**2. Connection pooling _____ database connections.**
**3. `CONN_MAX_AGE` controls _____ time.**
**4. List views use _____ serializers.**
**5. `GZipMiddleware` compresses _____ .**

## Answer Key

### Multiple Choice
1. C
2. A
3. A
4. C
5. A
6. A

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. reduces
2. reuses
3. connection lifetime
4. lightweight
5. responses

---

# Part 24: Automated Backend Testing

## Quiz 24.1: Multiple Choice

**1. What is the purpose of unit tests?**
- A) To test individual components in isolation
- B) To test component interactions
- C) To test user flows
- D) To test performance

**2. What is the purpose of fixtures in pytest?**
- A) To set up test data
- B) To mock external dependencies
- C) Both A and B
- D) None of the above

**3. Which library is used for backend testing in the masterclass?**
- A) pytest
- B) unittest
- C) doctest
- D) nose

**4. What is the purpose of `APIClient` in DRF?**
- A) To make API requests in tests
- B) To test API views
- C) Both A and B
- D) None of the above

**5. What is the purpose of test coverage?**
- A) To measure how much code is tested
- B) To identify untested code
- C) Both A and B
- D) None of the above

**6. What does `force_authenticate()` do?**
- A) Authenticates the test client
- B) Authenticates the user
- C) Both A and B
- D) None of the above

## Quiz 24.2: True/False

**1. Unit tests test individual components.** → True
**2. Fixtures are used to set up test data.** → True
**3. pytest is used for backend testing.** → True
**4. `APIClient` is used for integration tests.** → True
**5. Test coverage should be 100%.** → False

## Quiz 24.3: Fill in the Blanks

**1. _____ test individual components in isolation.**
**2. Fixtures set up _____ data.**
**3. pytest is the _____ framework.**
**4. `APIClient` makes _____ in tests.**
**5. Test coverage measures _____ code.**

## Answer Key

### Multiple Choice
1. A
2. C
3. A
4. C
5. C
6. A

### True/False
1. True
2. True
3. True
4. True
5. False

### Fill in the Blanks
1. Unit tests
2. test
3. testing
4. requests
5. tested

---

# Part 25: Frontend Testing

## Quiz 25.1: Multiple Choice

**1. What is the purpose of React Testing Library?**
- A) To test React components
- B) To test user interactions
- C) Both A and B
- D) None of the above

**2. What is the purpose of Playwright?**
- A) E2E testing
- B) Unit testing
- C) Component testing
- D) Integration testing

**3. What is the purpose of `screen.getByRole()`?**
- A) To find elements by ARIA role
- B) To find elements by text
- C) To find elements by ID
- D) To find elements by class

**4. What is the purpose of `fireEvent`?**
- A) To simulate user interactions
- B) To fire events
- C) Both A and B
- D) None of the above

**5. What is the purpose of `waitFor`?**
- A) To wait for asynchronous operations
- B) To wait for DOM updates
- C) Both A and B
- D) None of the above

**6. What is the purpose of E2E tests?**
- A) To test complete user flows
- B) To test individual components
- C) To test API endpoints
- D) To test database queries

## Quiz 25.2: True/False

**1. React Testing Library tests components.** → True
**2. Playwright is for E2E testing.** → True
**3. `getByRole` finds elements by ID.** → False
**4. `fireEvent` simulates user interactions.** → True
**5. `waitFor` waits for asynchronous operations.** → True

## Quiz 25.3: Fill in the Blanks

**1. React Testing Library tests _____ components.**
**2. Playwright is used for _____ testing.**
**3. `getByRole` finds by _____ .**
**4. `fireEvent` _____ user interactions.**
**5. `waitFor` waits for _____ operations.**

## Answer Key

### Multiple Choice
1. C
2. A
3. A
4. C
5. C
6. A

### True/False
1. True
2. True
3. False
4. True
5. True

### Fill in the Blanks
1. React
2. E2E
3. ARIA role
4. simulates
5. asynchronous

---

# Part 26: API Documentation

## Quiz 26.1: Multiple Choice

**1. What is the purpose of OpenAPI?**
- A) To describe REST APIs
- B) To generate API documentation
- C) Both A and B
- D) None of the above

**2. Which library is used for OpenAPI generation?**
- A) drf-spectacular
- B) drf-yasg
- C) drf-swagger
- D) drf-openapi

**3. What is the purpose of Swagger UI?**
- A) Interactive API documentation
- B) API testing
- C) Both A and B
- D) None of the above

**4. What is the purpose of ReDoc?**
- A) Clean API documentation
- B) Interactive API testing
- C) Both A and B
- D) None of the above

**5. What is the purpose of `@extend_schema`?**
- A) To add schema annotations to views
- B) To generate schema automatically
- C) Both A and B
- D) None of the above

**6. What is the purpose of `SpectacularAPIView`?**
- A) To serve OpenAPI schema
- B) To serve Swagger UI
- C) To serve ReDoc
- D) To serve API documentation

## Quiz 26.2: True/False

**1. OpenAPI is a specification for REST APIs.** → True
**2. drf-spectacular generates OpenAPI schema.** → True
**3. Swagger UI is interactive.** → True
**4. ReDoc is an API testing tool.** → False
**5. `@extend_schema` adds annotations to views.** → True

## Quiz 26.3: Fill in the Blanks

**1. OpenAPI describes _____ APIs.**
**2. _____ generates OpenAPI schema.**
**3. Swagger UI provides _____ documentation.**
**4. ReDoc provides _____ documentation.**
**5. `@extend_schema` adds _____ to views.**

## Answer Key

### Multiple Choice
1. C
2. A
3. C
4. A
5. A
6. A

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. REST
2. drf-spectacular
3. interactive
4. clean
5. annotations

---

# Part 27: Dockerizing Django

## Quiz 27.1: Multiple Choice

**1. What is the purpose of Docker?**
- A) To containerize applications
- B) To run virtual machines
- C) Both A and B
- D) None of the above

**2. What is a Docker image?**
- A) A template for creating containers
- B) A running container
- C) A Docker file
- D) A Docker volume

**3. What is the purpose of a multi-stage build?**
- A) To reduce image size
- B) To improve build speed
- C) Both A and B
- D) None of the above

**4. What is the purpose of `WORKDIR` in Dockerfile?**
- A) Sets the working directory
- B) Creates a working directory
- C) Both A and B
- D) None of the above

**5. What is the purpose of `HEALTHCHECK` in Dockerfile?**
- A) To check container health
- B) To monitor container performance
- C) Both A and B
- D) None of the above

**6. What is Gunicorn?**
- A) A WSGI server
- B) A web framework
- C) A database
- D) A cache

## Quiz 27.2: True/False

**1. Docker containers are lightweight.** → True
**2. Multi-stage builds reduce image size.** → True
**3. `WORKDIR` creates a directory.** → False
**4. `HEALTHCHECK` monitors container health.** → True
**5. Gunicorn is a WSGI server.** → True

## Quiz 27.3: Fill in the Blanks

**1. Docker _____ applications.**
**2. Images are _____ for containers.**
**3. Multi-stage builds _____ image size.**
**4. `WORKDIR` sets the _____ directory.**
**5. `HEALTHCHECK` checks _____ health.**

## Answer Key

### Multiple Choice
1. A
2. A
3. C
4. A
5. A
6. A

### True/False
1. True
2. True
3. False
4. True
5. True

### Fill in the Blanks
1. containerizes
2. templates
3. reduce
4. working
5. container

---

# Part 28: Dockerizing Next.js

## Quiz 28.1: Multiple Choice

**1. What is the purpose of standalone output in Next.js?**
- A) To create a self-contained deployment
- B) To reduce build size
- C) Both A and B
- D) None of the above

**2. What is the difference between dev and production images?**
- A) Dev images are larger
- B) Production images are optimized
- C) Both A and B
- D) None of the above

**3. What is the purpose of `.dockerignore`?**
- A) To exclude files from Docker build
- B) To include files in Docker build
- C) Both A and B
- D) None of the above

**4. What is the purpose of `USER nextjs` in Dockerfile?**
- A) To run as a non-root user
- B) To run as root
- C) Both A and B
- D) None of the above

**5. What is the purpose of `EXPOSE` in Dockerfile?**
- A) To document the port
- B) To expose the port
- C) Both A and B
- D) None of the above

**6. How do you reduce the image size of a Next.js app?**
- A) Use standalone output
- B) Use multi-stage builds
- C) Both A and B
- D) None of the above

## Quiz 28.2: True/False

**1. Standalone output creates a self-contained deployment.** → True
**2. Production images are larger than dev images.** → False
**3. `.dockerignore` excludes files from Docker build.** → True
**4. `USER nextjs` runs as root.** → False
**5. `EXPOSE` documents the port.** → True

## Quiz 28.3: Fill in the Blanks

**1. Standalone output creates a _____ deployment.**
**2. Production images are _____ .**
**3. `.dockerignore` _____ files from Docker build.**
**4. `USER nextjs` runs as _____ user.**
**5. `EXPOSE` _____ the port.**

## Answer Key

### Multiple Choice
1. C
2. C
3. A
4. A
5. A
6. C

### True/False
1. True
2. False
3. True
4. False
5. True

### Fill in the Blanks
1. self-contained
2. optimized
3. excludes
4. non-root
5. documents

---

# Part 29: Docker Compose

## Quiz 29.1: Multiple Choice

**1. What is the purpose of Docker Compose?**
- A) To run multi-container applications
- B) To build Docker images
- C) Both A and B
- D) None of the above

**2. What is the purpose of `depends_on`?**
- A) To define service dependencies
- B) To define service dependencies
- C) Both A and B
- D) None of the above

**3. What is the purpose of volumes in Docker Compose?**
- A) To persist data
- B) To share data between containers
- C) Both A and B
- D) None of the above

**4. What is the purpose of networks in Docker Compose?**
- A) To enable communication between services
- B) To isolate services
- C) Both A and B
- D) None of the above

**5. What is the purpose of `restart` policy?**
- A) To automatically restart containers
- B) To stop containers
- C) Both A and B
- D) None of the above

**6. What is the purpose of health checks in Docker Compose?**
- A) To check container health
- B) To monitor container performance
- C) Both A and B
- D) None of the above

## Quiz 29.2: True/False

**1. Docker Compose runs multi-container applications.** → True
**2. `depends_on` defines service dependencies.** → True
**3. Volumes persist data.** → True
**4. Networks isolate services.** → True
**5. Health checks monitor container health.** → True

## Quiz 29.3: Fill in the Blanks

**1. Docker Compose runs _____ applications.**
**2. `depends_on` defines _____ dependencies.**
**3. Volumes _____ data.**
**4. Networks enable _____ between services.**
**5. Health checks monitor _____ health.**

## Answer Key

### Multiple Choice
1. A
2. C
3. C
4. C
5. A
6. A

### True/False
1. True
2. True
3. True
4. True
5. True

### Fill in the Blanks
1. multi-container
2. service
3. persist
4. communication
5. container

---

# Part 30: Production Configuration

## Quiz 30.1: Multiple Choice

**1. Why should `DEBUG` be `False` in production?**
- A) To prevent sensitive information exposure
- B) To improve performance
- C) Both A and B
- D) None of the above

**2. What is the purpose of `ALLOWED_HOSTS`?**
- A) To restrict which hosts can access the app
- B) To prevent host header attacks
- C) Both A and B
- D) None of the above

**3. What is the purpose of `SECURE_SSL_REDIRECT`?**
- A) To redirect HTTP to HTTPS
- B) To enable SSL
- C) Both A and B
- D) None of the above

**4. What is the purpose of `SESSION_COOKIE_SECURE`?**
- A) To send cookies over HTTPS only
- B) To secure cookies
- C) Both A and B
- D) None of the above

**5. What is the purpose of `CSRF_COOKIE_SECURE`?**
- A) To send CSRF cookies over HTTPS only
- B) To secure CSRF cookies
- C) Both A and B
- D) None of the above

**6. What is the purpose of `SECURE_HSTS_SECONDS`?**
- A) To enable HSTS
- B) To set HSTS duration
- C) Both A and B
- D) None of the above

## Quiz 30.2: True/False

**1. `DEBUG` should be `False` in production.** → True
**2. `ALLOWED_HOSTS` prevents host header attacks.** → True
**3. `SECURE_SSL_REDIRECT` redirects HTTP to HTTPS.** → True
**4. `SESSION_COOKIE_SECURE` sends cookies over HTTP.** → False
**5. `CSRF_COOKIE_SECURE` sends CSRF cookies over HTTPS.** → True

## Quiz 30.3: Fill in the Blanks

**1. `DEBUG` should be _____ in production.**
**2. `ALLOWED_HOSTS` prevents _____ attacks.**
**3. `SECURE_SSL_REDIRECT` redirects _____ .**
**4. `SESSION_COOKIE_SECURE` sends cookies over _____ .**
**5. `CSRF_COOKIE_SECURE` sends CSRF cookies over _____ .**

## Answer Key

### Multiple Choice
1. C
2. C
3. A
4. C
5. C
6. C

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. False
2. host header
3. HTTP to HTTPS
4. HTTPS
5. HTTPS

---

# Part 31: Reverse Proxy & Networking

## Quiz 31.1: Multiple Choice

**1. What is the purpose of Nginx in the application?**
- A) Reverse proxy
- B) Load balancer
- C) Both A and B
- D) None of the above

**2. What is the purpose of SSL/TLS?**
- A) To encrypt data in transit
- B) To authenticate the server
- C) Both A and B
- D) None of the above

**3. What is the purpose of `proxy_pass` in Nginx?**
- A) To forward requests to upstream servers
- B) To proxy requests
- C) Both A and B
- D) None of the above

**4. What is the purpose of HSTS?**
- A) To enforce HTTPS
- B) To prevent SSL stripping
- C) Both A and B
- D) None of the above

**5. What is the purpose of rate limiting in Nginx?**
- A) To prevent abuse
- B) To protect against DDoS attacks
- C) Both A and B
- D) None of the above

**6. What is the purpose of security headers?**
- A) To protect against web vulnerabilities
- B) To secure the application
- C) Both A and B
- D) None of the above

## Quiz 31.2: True/False

**1. Nginx is a reverse proxy.** → True
**2. SSL/TLS encrypts data in transit.** → True
**3. `proxy_pass` forwards requests to upstream servers.** → True
**4. HSTS enforces HTTPS.** → True
**5. Rate limiting prevents abuse.** → True

## Quiz 31.3: Fill in the Blanks

**1. Nginx is a _____ proxy.**
**2. SSL/TLS _____ data in transit.**
**3. `proxy_pass` _____ requests to upstream servers.**
**4. HSTS enforces _____ .**
**5. Rate limiting prevents _____ .**

## Answer Key

### Multiple Choice
1. C
2. C
3. C
4. C
5. C
6. C

### True/False
1. True
2. True
3. True
4. True
5. True

### Fill in the Blanks
1. reverse
2. encrypts
3. forwards
4. HTTPS
5. abuse

---

# Part 32: CI/CD

## Quiz 32.1: Multiple Choice

**1. What does CI/CD stand for?**
- A) Continuous Integration / Continuous Deployment
- B) Continuous Integration / Continuous Delivery
- C) Both A and B
- D) None of the above

**2. What is the purpose of CI?**
- A) To automate testing on code changes
- B) To integrate code changes regularly
- C) Both A and B
- D) None of the above

**3. What is the purpose of CD?**
- A) To automate deployment
- B) To deliver changes to users
- C) Both A and B
- D) None of the above

**4. What is the purpose of GitHub Actions?**
- A) To automate workflows
- B) To run CI/CD pipelines
- C) Both A and B
- D) None of the above

**5. What is the typical flow in CI/CD?**
- A) Test → Build → Deploy
- B) Build → Test → Deploy
- C) Deploy → Test → Build
- D) Test → Deploy → Build

**6. What is the purpose of a deployment stage?**
- A) To deploy the application
- B) To run tests
- C) Both A and B
- D) None of the above

## Quiz 32.2: True/False

**1. CI automates testing.** → True
**2. CD automates deployment.** → True
**3. GitHub Actions is a CI/CD tool.** → True
**4. The typical flow is Build → Test → Deploy.** → False
**5. Deployment stages deploy the application.** → True

## Quiz 32.3: Fill in the Blanks

**1. CI stands for _____ .**
**2. CD stands for _____ .**
**3. CI _____ testing on code changes.**
**4. CD _____ deployment.**
**5. GitHub Actions automates _____ .**

## Answer Key

### Multiple Choice
1. C
2. C
3. C
4. C
5. A
6. A

### True/False
1. True
2. True
3. True
4. False
5. True

### Fill in the Blanks
1. Continuous Integration
2. Continuous Deployment
3. automates
4. automates
5. workflows

---

# Part 33: Observability & Production Operations

## Quiz 33.1: Multiple Choice

**1. What are the three pillars of observability?**
- A) Logs, Metrics, Traces
- B) Logs, Metrics, Alerts
- C) Metrics, Traces, Alerts
- D) Logs, Traces, Alerts

**2. What is the purpose of structured logging?**
- A) To make logs searchable and analyzable
- B) To format logs consistently
- C) Both A and B
- D) None of the above

**3. What is the purpose of Sentry?**
- A) Error tracking
- B) Performance monitoring
- C) Both A and B
- D) None of the above

**4. What is the purpose of Prometheus?**
- A) Metrics collection
- B) Alerting
- C) Both A and B
- D) None of the above

**5. What is the purpose of Grafana?**
- A) Dashboard visualization
- B) Metrics analysis
- C) Both A and B
- D) None of the above

**6. What is the purpose of alerts?**
- A) To notify the team of issues
- B) To monitor system health
- C) Both A and B
- D) None of the above

## Quiz 33.2: True/False

**1. The three pillars are Logs, Metrics, and Traces.** → True
**2. Structured logging makes logs searchable.** → True
**3. Sentry is an error tracking tool.** → True
**4. Prometheus collects metrics.** → True
**5. Grafana creates dashboards.** → True

## Quiz 33.3: Fill in the Blanks

**1. The three pillars are _____, _____, and _____ .**
**2. Structured logging makes logs _____ .**
**3. Sentry is an _____ tracking tool.**
**4. Prometheus collects _____ .**
**5. Grafana creates _____ .**

## Answer Key

### Multiple Choice
1. A
2. C
3. C
4. C
5. C
6. C

### True/False
1. True
2. True
3. True
4. True
5. True

### Fill in the Blanks
1. Logs, Metrics, Traces
2. searchable
3. error
4. metrics
5. dashboards

---

*This completes the Quiz and Test Bank for the Django REST Framework & Next.js 16 masterclass.*
