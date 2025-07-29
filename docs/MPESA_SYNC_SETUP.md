# M-Pesa Transaction Sync Setup Guide

This guide will help you set up automatic M-Pesa transaction syncing for the Expense Tracker app.

## 🎯 Overview

The M-Pesa sync system automatically:
1. **Reads M-Pesa SMS messages** from your phone
2. **Parses transaction details** (amount, merchant, type)
3. **Stores raw transactions** in `mpesa_transactions` table
4. **Auto-converts to expenses** using database triggers
5. **Categorizes transactions** for easy tracking

## 📋 Prerequisites

- ✅ Supabase project set up
- ✅ Flutter app configured with Supabase
- ✅ Android device (SMS permissions required)
- ✅ M-Pesa account with SMS notifications enabled

## 🗄️ Database Setup

### Step 1: Apply Database Schema

Run the SQL schema in your Supabase dashboard:

```bash
# Copy and paste the contents of scripts/apply_schema.sql
# into your Supabase SQL Editor and execute
```

Or use the command line:
```bash
psql -h your-supabase-host -U postgres -d postgres -f scripts/apply_schema.sql
```

### Step 2: Verify Tables Created

Check that these tables exist:
- ✅ `categories` - Expense categories
- ✅ `expenses` - Individual expense records  
- ✅ `mpesa_transactions` - Raw M-Pesa SMS data

### Step 3: Test Database Connection

```dart
dart run scripts/test_mpesa_sync.dart \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

## 📱 App Integration

### Step 1: Request SMS Permissions

The app will automatically request SMS permissions when you:
1. Open the **M-Pesa Linking** screen
2. Tap **"Link M-Pesa Account"**
3. Grant SMS permissions when prompted

### Step 2: Initial Sync

After granting permissions:
1. The app scans **last 30 days** of SMS messages
2. Finds M-Pesa transaction messages
3. Parses and saves them to database
4. Auto-converts to expense records

### Step 3: Real-time Monitoring

Once set up, the app will:
- ✅ **Monitor new SMS** messages in real-time
- ✅ **Auto-process M-Pesa** transactions immediately
- ✅ **Sync every 30 minutes** for missed messages
- ✅ **Handle offline scenarios** gracefully

## 🔧 Supported M-Pesa Transaction Types

### ✅ Automatically Tracked (Expenses)
- **Sent Money**: `You have sent Ksh500.00 to JOHN DOE`
- **Bill Payments**: `Ksh1,200.00 paid to KPLC PREPAID`
- **Buy Goods**: `Ksh250.00 paid to JAVA HOUSE`
- **Cash Withdrawals**: `You have withdrawn Ksh1,000.00`

### ℹ️ Recorded but Not Tracked (Income)
- **Received Money**: `You have received Ksh500.00 from JANE`
- **Deposits**: `You have deposited Ksh1,000.00`

## 🎨 SMS Message Examples

The parser handles various M-Pesa SMS formats:

```
ABC123 Confirmed. You have sent Ksh500.00 to JAVA HOUSE. 
New M-PESA balance is Ksh2,500.00 on 15/1/24 at 2:30 PM.

DEF456 Confirmed. Ksh1,200.00 paid to KPLC PREPAID for account 123456. 
New M-PESA balance is Ksh1,300.00 on 15/1/24 at 1:15 PM.

GHI789 Confirmed. Ksh250.00 paid to UBER KENYA. 
New M-PESA balance is Ksh1,050.00 on 15/1/24 at 12:45 PM.
```

## 🔒 Security & Privacy

### Data Protection
- ✅ **Row Level Security (RLS)** - Users only see their own data
- ✅ **Local SMS processing** - SMS content never leaves your device
- ✅ **Encrypted transmission** - All data encrypted in transit
- ✅ **Minimal data storage** - Only transaction details stored

### Permissions
- 📱 **SMS Read Permission** - Required to read M-Pesa messages
- 📱 **Phone Permission** - Required by Android for SMS access
- 🚫 **No other permissions** - App doesn't access contacts, location, etc.

## 🐛 Troubleshooting

### SMS Permissions Denied
```
❌ Error: SMS permissions are required for M-Pesa sync
```
**Solution**: Go to Android Settings > Apps > Expense Tracker > Permissions > Enable SMS

### No Transactions Found
```
ℹ️ No new M-Pesa transactions found
```
**Possible causes**:
- No M-Pesa SMS messages in last 30 days
- SMS messages from different sender (not "MPESA")
- SMS format not recognized by parser

### Database Connection Issues
```
❌ Failed to sync: Connection timeout
```
**Solution**: Check internet connection and Supabase configuration

### Duplicate Transactions
```
ℹ️ Transaction ABC123 already exists
```
**This is normal** - The system prevents duplicate transactions automatically

## 📊 Monitoring Sync Status

### In the App
- 🟢 **Green indicator**: Sync successful
- 🟡 **Yellow indicator**: Offline mode (pending sync)
- 🔴 **Red indicator**: Sync error
- 🔄 **Spinning**: Currently syncing

### Manual Sync
- Pull down on transactions screen to refresh
- Or tap the sync button in M-Pesa linking screen

## 🚀 Advanced Configuration

### Adjust Sync Frequency
Edit `UnifiedMpesaSyncService`:
```dart
// Change from 30 minutes to desired interval
Timer.periodic(const Duration(minutes: 15), (_) => syncHistoricalSms());
```

### Custom SMS Patterns
Add new patterns to `MpesaSmsParser`:
```dart
// Add support for new M-Pesa SMS formats
final newPattern = RegExp(r'your_custom_pattern');
```

### Database Triggers
The system uses PostgreSQL triggers to auto-convert M-Pesa transactions to expenses. See `convert_mpesa_to_expense()` function in the schema.

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Run the test script to verify setup
3. Check Supabase logs for database errors
4. Ensure SMS permissions are granted

## 🎉 Success Indicators

You'll know the sync is working when:
- ✅ SMS permissions granted successfully
- ✅ Historical transactions appear in app
- ✅ New M-Pesa transactions auto-appear
- ✅ Transactions are properly categorized
- ✅ Sync status shows green/success

Happy expense tracking! 💰📱
