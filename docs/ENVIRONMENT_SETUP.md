# Environment Setup Guide

## Overview

This project uses environment files to manage configuration settings for different deployment environments. Environment files contain sensitive information like API keys and should never be committed to version control.

## Environment Files

### Available Files

- `.env` - Default/local development configuration
- `.env.development` - Development environment settings
- `.env.production` - Production environment settings
- `.env.example` - Template file with example values

### Setup Instructions

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual values:**
   - Get your Supabase URL and Anon Key from your [Supabase dashboard](https://supabase.com/dashboard)
   - Update other settings as needed for your environment

3. **For different environments:**
   - Development: Use `.env.development`
   - Production: Use `.env.production`
   - Local: Use `.env`

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ENVIRONMENT` | Current environment | `local`, `development`, `production` |
| `DEVELOPER_MODE_ENABLED` | Enable developer features | `true` / `false` |
| `DEBUG_INFO` | Show debug information | `true` / `false` |
| `SUPABASE_URL` | Your Supabase project URL | `https://your-project-id.supabase.co` |
| `SUPABASE_ANON_KEY` | Your Supabase anon key | `your_supabase_anon_key_here` |
| `API_TIMEOUT` | API request timeout (ms) | `5000`, `10000` |
| `MAX_RETRIES` | Maximum retry attempts | `2`, `3` |

## Environment Loading

The app automatically loads the appropriate environment file based on the Flutter build mode:

- **Debug builds** → `.env.development`
- **Release builds** → `.env.production`  
- **Profile builds** → `.env`

## Security Notes

⚠️ **Important Security Practices:**

1. **Never commit .env files** - They contain sensitive information
2. **Use different keys for different environments** - Don't reuse production keys in development
3. **Rotate keys regularly** - Especially if they may have been exposed
4. **Use row-level security** - Configure proper RLS policies in Supabase

## Troubleshooting

### Missing Environment File
If you see environment loading errors, ensure you have created the appropriate `.env` file for your build mode.

### Supabase Connection Issues
1. Verify your `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
2. Check your Supabase project is active
3. Ensure your RLS policies allow the operations you're trying to perform

### Local Development
For local development, you can use the default `.env` file with development settings enabled.