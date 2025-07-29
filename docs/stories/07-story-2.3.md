# Story 2.3: Custom Category Creation & Management

**As a** user,
**I want** to create and manage my own expense categories,
**so that** I can organize my spending in a way that makes sense to me.

## 📋 **Current Application State (Story 2.2 Complete)**

### ✅ **Completed Features**
- **Story 2.1**: Professional transaction categorization system with real-time sync
- **Story 2.2**: Advanced categorization with modal interface, bulk operations, and offline support
- **M-Pesa Integration**: Fully functional SMS-based transaction syncing with automatic categorization

### 🗄️ **Database Schema (Ready)**
```sql
-- Categories table structure (already exists)
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid NULL,  -- NULL = default categories, UUID = user custom categories
  name text NOT NULL,
  icon text NULL DEFAULT 'faFolder',
  color text NULL DEFAULT '#667eea',
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- RLS Policies (already configured)
-- Users can see default categories (user_id IS NULL) + their own custom categories
-- Users can CRUD their own custom categories only
```

### 🎨 **Design System (Available)**
- **Theme**: `lib/src/shared/theme.dart` with glassmorphic cards and gradients
- **Colors**: `AppColors` with primary gradients, accent colors, and category colors
- **Components**: `AppTheme.buildGlassmorphicCard()` for consistent UI
- **Icons**: FontAwesome integration via `CategoryIconMapper`

### 🏗️ **Architecture (Established)**
```
lib/src/features/categories/
├── data/
│   └── category_repository.dart          # Full CRUD operations ready
├── domain/
│   └── category.dart                     # Domain model complete
└── presentation/
    └── widgets/
        ├── category_icon_mapper.dart     # Icon mapping system
        └── category_selection_widget.dart # Reusable category picker
```

### 🔧 **Services (Ready to Use)**
- **CategoryRepository**: Complete CRUD operations with local caching
- **Category Selection Widget**: Professional UI component for category picking
- **Real-time Sync**: Categories sync across devices via Supabase
- **Offline Support**: Local database with sync when online

### 📱 **Current Category System**
- **12 Default Categories**: Food & Dining, Transportation, Shopping, Bills & Utilities, Entertainment, Health & Medical, Education, Travel, Business, Personal Care, Gifts & Donations, Uncategorized
- **Icon System**: FontAwesome icons with `CategoryIconMapper.getIcon(iconName)`
- **Color System**: Hex colors with proper parsing and display
- **Selection Interface**: Grid-based picker with search and recent categories

## Acceptance Criteria

1. **Categories Management Screen**: Create a dedicated screen for category management
2. **Category List Display**: Show default categories (read-only) and custom categories (editable)
3. **Add New Category**: Form with name, icon picker, and color picker
4. **Edit Custom Categories**: Modify name, icon, and color of user-created categories
5. **Delete Custom Categories**: Remove custom categories with proper transaction handling
6. **Integration**: Custom categories appear in existing category selection interfaces
7. **Validation**: Prevent duplicate names, ensure required fields, handle edge cases

## 🎯 **Implementation Requirements**

### **UI Components Needed**
1. **Categories Management Screen** (`categories_management_screen.dart`)
   - List of all categories (default + custom)
   - Add/Edit/Delete actions
   - Professional glassmorphic design

2. **Category Form Modal** (`category_form_modal.dart`)
   - Name input field
   - Icon picker grid (FontAwesome icons)
   - Color picker with predefined palette
   - Save/Cancel actions

3. **Category List Item** (`category_list_item.dart`)
   - Display category with icon and color
   - Edit/Delete actions for custom categories
   - Read-only display for default categories

### **Business Logic**
1. **Validation Rules**:
   - Category name: 1-50 characters, unique per user
   - Icon: Must be valid FontAwesome icon name
   - Color: Valid hex color code

2. **Deletion Handling**:
   - When custom category is deleted, reassign transactions to "Uncategorized"
   - Prevent deletion if category has recent transactions (optional warning)

3. **Integration Points**:
   - Update `CategorySelectionWidget` to include custom categories
   - Refresh category lists in transaction screens
   - Sync custom categories across devices

### **Navigation Integration**
- Add "Manage Categories" option to main navigation or settings
- Accessible from transaction categorization interface
- Deep linking support for category management

## 🔧 **Technical Implementation Notes**

### **Repository Usage**
```dart
// CategoryRepository methods already available:
await categoryRepository.createCategory(category);  // Create custom category
await categoryRepository.updateCategory(category);  // Update custom category
await categoryRepository.deleteCategory(categoryId); // Delete custom category
await categoryRepository.fetchCategories();         // Get all categories (default + custom)
```

### **Database Considerations**
- **RLS Policies**: Already configured for user isolation
- **Foreign Key Constraints**: Expenses table references categories
- **Cascade Handling**: Need to handle category deletion gracefully
- **Indexing**: Performance indexes already in place

### **UI Consistency**
- **Follow existing patterns**: Use same modal style as `TransactionDetailModal`
- **Color scheme**: Maintain `AppColors` consistency
- **Animations**: Use existing animation controllers and transitions
- **Icons**: Leverage `CategoryIconMapper` for consistent icon handling

### **Error Handling**
- **Network errors**: Graceful offline handling
- **Validation errors**: Clear user feedback
- **Deletion conflicts**: Handle transactions with deleted categories
- **Duplicate names**: Prevent and provide feedback

## 🚀 **Success Metrics**
- **User Adoption**: >30% of users create at least one custom category
- **Performance**: Category operations complete in <500ms
- **Reliability**: <1% error rate for category operations
- **UX**: Intuitive interface with minimal learning curve

## 📚 **Reference Files**
- **Database Schema**: `supabase/database_schema.sql`
- **Theme System**: `lib/src/shared/theme.dart`
- **Category Repository**: `lib/src/features/categories/data/category_repository.dart`
- **Category Selection**: `lib/src/features/categories/presentation/widgets/category_selection_widget.dart`
- **Icon Mapping**: `lib/src/features/categories/presentation/widgets/category_icon_mapper.dart`

## 🎨 **Design Requirements**
- **Consistent with existing UI**: Follow transaction screen design patterns
- **Glassmorphic cards**: Use `AppTheme.buildGlassmorphicCard()`
- **Professional animations**: Smooth transitions and micro-interactions
- **Responsive design**: Works on different screen sizes
- **Accessibility**: Proper labels and contrast ratios

This story builds upon the solid foundation established in Stories 2.1 and 2.2, extending the categorization system with user customization capabilities while maintaining the professional design and robust architecture already in place.
