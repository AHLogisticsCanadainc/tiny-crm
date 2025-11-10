# Tiny CRM - Setup Instructions

## Current Status

✅ Database schema created in Supabase
✅ Admin user created
✅ Environment configuration complete

## Important Information

### Admin Login Credentials
- **Email**: admin@example.com
- **Password**: password

### Database Connection
The application is configured to use Supabase PostgreSQL database:
- Host: aws-0-us-east-1.pooler.supabase.com
- Port: 6543
- Database: postgres
- Username: postgres.jbegjeqpnggfqicthved

**Note**: You need to add your Supabase database password to the `.env` file at line 16 (DB_PASSWORD=)

## How to Run the Application

### Prerequisites
Since this is a Laravel PHP application, you need:
1. PHP 8.2 or higher installed
2. Composer installed
3. Node.js and npm (already installed)

### Setup Steps

1. **Install PHP Dependencies**
   ```bash
   composer install
   ```

2. **Add Database Password**
   Edit the `.env` file and add your Supabase database password:
   ```
   DB_PASSWORD=your_supabase_password_here
   ```

   To find your Supabase password:
   - Go to your Supabase project dashboard
   - Navigate to Settings > Database
   - Look for the "Connection string" or "Database password"

3. **Generate Application Key**
   ```bash
   php artisan key:generate
   ```

4. **Clear Configuration Cache**
   ```bash
   php artisan config:clear
   php artisan cache:clear
   ```

5. **Build Frontend Assets**
   ```bash
   npm run build
   ```

6. **Start the Laravel Development Server**
   ```bash
   php artisan serve
   ```

   The application will be available at: http://localhost:8000

7. **Access the CRM**
   - Open your browser and go to: http://localhost:8000
   - You'll be redirected to: http://localhost:8000/app/login
   - Login with the credentials above

## Optional: Seed Sample Data

If you want to populate the database with sample data:

```bash
php artisan db:seed
```

This will create sample accounts, contacts, leads, deals, and products.

## Troubleshooting

### Issue: "php command not found"
You need to install PHP. Visit https://www.php.net/downloads.php

### Issue: Database connection error
- Verify your Supabase password is correct in `.env`
- Check that your IP address is allowed in Supabase project settings
- Ensure the database credentials are correct

### Issue: "Class not found" errors
Run: `composer dump-autoload`

### Issue: Permission errors
Make sure storage and cache directories are writable:
```bash
chmod -R 775 storage bootstrap/cache
```

## What's Been Set Up

1. **Database Tables Created**:
   - users (for CRM login)
   - accounts (customer companies)
   - contacts (individual people)
   - leads (sales opportunities)
   - deals (qualified sales)
   - products (items/services)
   - deal_products (products in deals)

2. **Row Level Security (RLS)**:
   - All tables have RLS enabled
   - Authenticated users can manage all records
   - Suitable for internal CRM use

3. **Admin User**:
   - Created with email: admin@example.com
   - Password: password
   - You can create more users from the CRM after logging in

## Next Steps

After logging in, you can:
- Create new accounts and contacts
- Track leads through the sales pipeline
- Convert qualified leads to deals
- Add products to deals
- View analytics and reports on the dashboard

## Support

For Laravel documentation: https://laravel.com/docs
For Filament documentation: https://filamentphp.com/docs
