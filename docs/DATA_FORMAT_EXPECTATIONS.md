# Data Format Expectations for Matching

## Overview
To ensure accurate matching, profile fields now use **standardized dropdown options** with automatic normalization. This prevents matching issues caused by inconsistent data entry.

---

## Standardized Fields (Dropdown Selects)

### 1. Sleep Schedule
**Field Type**: Dropdown select  
**Options**:
- `Early Bird` - Wakes up early, goes to bed early
- `Night Owl` - Stays up late, wakes up late
- `Regular Schedule` - Consistent sleep/wake times
- `Flexible` - Varies or adaptable

**Auto-Normalization**: 
- "early", "morning", "earlybird" → `Early Bird`
- "night", "late", "nightowl" → `Night Owl`
- "regular", "normal", "standard" → `Regular Schedule`
- "flexible", "varies" → `Flexible`

**Matching**: Exact match required (case-insensitive)

---

### 2. Pets
**Field Type**: Dropdown select  
**Options**:
- `None` - No pets
- `Cat` - Has cat(s)
- `Dog` - Has dog(s)
- `Other` - Other pets
- `Pet Friendly` - Open to living with pets

**Auto-Normalization**:
- "no", "none", "no pets" → `None`
- "cat", "cats" → `Cat`
- "dog", "dogs", "puppy" → `Dog`
- "pet friendly", "ok with pets" → `Pet Friendly`
- "other", "different" → `Other`

**Matching**: 
- Exact match OR
- `Pet Friendly` matches with any pet type
- `None` only matches with `None` or `Pet Friendly`

---

### 3. Housing Status
**Field Type**: Dropdown select  
**Options**:
- `Looking for Room` - Seeking a room to rent
- `Looking for Roommate` - Have a place, need roommate
- `Have Room Available` - Have room to rent out
- `Flexible` - Open to either situation

**Auto-Normalization**:
- "looking for room", "need room", "seeking room" → `Looking for Room`
- "looking for roommate", "need roommate" → `Looking for Roommate`
- "have room", "room available" → `Have Room Available`
- "flexible", "either", "both" → `Flexible`

**Matching**: Currently not used in algorithm (planned for Phase 3)

---

## Free-Text Fields (Still Manual Entry)

### 4. Preferred Location
**Field Type**: Text input  
**Format**: Free text (e.g., "Manhattan", "Brooklyn", "Queens")

**Auto-Normalization**:
- Strips extra spaces
- Titleizes (e.g., "manhattan" → "Manhattan")
- Handles common variations:
  - "NYC", "New York City", "NY" → matches with "New York"
  - "BK", "Bklyn" → matches with "Brooklyn"
  - "SI" → matches with "Staten Island"

**Matching**: 
- Exact match (case-insensitive) OR
- Recognized location variations

**Examples**:
- ✅ "Manhattan" matches "manhattan"
- ✅ "NYC" matches "New York"
- ✅ "Brooklyn" matches "BK"
- ❌ "Manhattan" does NOT match "Brooklyn"

---

### 5. Budget
**Field Type**: Number input  
**Format**: Integer (dollars per month)

**Validation**:
- Must be >= 0
- Numeric only

**Matching**: 
- Calculates similarity: `1 - (budget_difference / average_budget)`
- Closer budgets = higher match score
- Example: $1500 vs $1600 = ~97% budget match

---

## How Normalization Works

### Automatic Normalization on Save
When a user saves their profile, the `User` model automatically normalizes values:

```ruby
before_save :normalize_profile_fields
```

This ensures:
1. **Consistent formatting** - All values use standard format
2. **Variation handling** - Common variations are mapped to standard values
3. **Better matching** - Standardized values improve match accuracy

### Example Normalization Flow

**User enters**: "early bird" (lowercase, with space)
**System normalizes to**: "Early Bird" (standard format)
**Stored in database**: "Early Bird"
**Matches with**: "Early Bird", "early bird", "EarlyBird", etc.

---

## Data Entry Best Practices

### For Users:
1. **Use dropdowns** - Select from provided options when available
2. **Be consistent** - If entering free text, use standard formats
3. **Update profile** - Matches regenerate automatically when you save

### For Developers:
1. **Always normalize** - Use `before_save` callbacks
2. **Validate options** - Check against standard options list
3. **Handle variations** - Map common variations to standards

---

## Migration Notes

### Existing Data
If you have existing users with free-text values:
- The normalization will run on next profile update
- Old values will be converted to standard format
- Matches will improve after normalization

### Backward Compatibility
- Old free-text values are still supported
- Normalization handles common variations
- Dropdowns prevent future inconsistencies

---

## Code Locations

### Normalization Logic
- **File**: `app/models/user.rb`
- **Method**: `normalize_profile_fields` (private)
- **Helpers**: `normalize_sleep_schedule`, `normalize_pets`, `normalize_housing_status`

### Matching Logic
- **File**: `app/models/match.rb`
- **Methods**: `locations_match?`, `pets_compatible?`
- **Improvements**: Handles variations and synonyms

### Form Fields
- **File**: `app/views/profiles/edit.html.erb`
- **Fields**: Sleep Schedule, Pets, Housing Status (dropdowns)
- **Fields**: Preferred Location, Budget (text/number inputs)

---

## Summary

**Standardized (Dropdowns)**:
- ✅ Sleep Schedule - 4 options
- ✅ Pets - 5 options  
- ✅ Housing Status - 4 options

**Free-Text (With Normalization)**:
- ✅ Preferred Location - Auto-titleized, handles variations
- ✅ Budget - Numeric validation

**Benefits**:
- ✅ Consistent data format
- ✅ Better matching accuracy
- ✅ Handles user variations automatically
- ✅ Prevents matching failures due to typos/formatting

