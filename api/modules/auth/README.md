# Auth Module - Login with Email or Username

Authentication module that supports login using either email or username.

## 📡 API Endpoints

### Register

```
POST /api/v1/auth/register
```

**Request Body:**
```json
{
  "name": "John Doe",
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "created_at": "2025-01-20T10:00:00Z",
      "updated_at": "2025-01-20T10:00:00Z"
    }
  }
}
```

---

### Login (with Email or Username)

```
POST /api/v1/auth/login
```

**Request Body (using email):**
```json
{
  "identity": "john@example.com",
  "password": "password123"
}
```

**Request Body (using username):**
```json
{
  "identity": "johndoe",
  "password": "password123"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "created_at": "2025-01-20T10:00:00Z",
      "updated_at": "2025-01-20T10:00:00Z"
    }
  }
}
```

---

## 🔑 How Login Works

### Identity Field

The `identity` field accepts **either email or username**:

```go
// Backend checks both
SELECT * FROM users 
WHERE email = ? OR username = ?
```

### Flow:

1. User sends `identity` (email or username) + `password`
2. System searches database for matching email OR username
3. If found, verify password
4. Return JWT token + user data

### Examples:

```bash
# Login with email
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "john@example.com",
    "password": "password123"
  }'

# Login with username
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "johndoe",
    "password": "password123"
  }'
```

---

## 🔧 Implementation Details

### Repository Layer

Added new methods to `UserRepository`:

```go
// Find user by username
FindByUsername(ctx context.Context, username string) (*entity.User, error)

// Find user by email OR username
FindByIdentity(ctx context.Context, identity string) (*entity.User, error)
```

**Implementation:**

```go
func (r UserRepositoryImpl) FindByIdentity(ctx context.Context, identity string) (*entity.User, error) {
    var user entity.User
    result := database.DB.WithContext(ctx).
        Where("email = ? OR username = ?", identity, identity).
        First(&user)
    
    if result.Error != nil {
        if result.RowsAffected == 0 {
            return nil, ERR_RECORD_NOT_FOUND
        }
        return nil, result.Error
    }
    return &user, nil
}
```

### Service Layer

Updated `ProcessLogin` to accept identity:

```go
func (s *AuthService) ProcessLogin(ctx context.Context, identity, password string) (*entity.User, error) {
    // Validate input
    if identity == "" || password == "" {
        return nil, errors.New("identity and password cannot be empty")
    }
    
    // Find user by email or username
    existingUser, err := s.userRepo.FindByIdentity(ctx, identity)
    if err != nil {
        if err == repository.ERR_RECORD_NOT_FOUND {
            return nil, ErrUserNotFound
        }
        return nil, err
    }
    
    // Verify password
    if !utils.CompareHashAndPassword(existingUser.Password, password) {
        return nil, ErrInvalidPassword
    }
    
    return existingUser, nil
}
```

### Handler Layer

Updated to use `identity` field:

```go
func (h *AuthHandler) Login(c echo.Context) error {
    req := new(request.LoginRequest)
    // ... binding & validation
    
    user, err := h.authService.ProcessLogin(c.Request().Context(), req.Identity, req.Password)
    // ... error handling & token generation
}
```

### DTO Layer

Updated `LoginRequest`:

```go
type LoginRequest struct {
    Identity string `json:"identity" validate:"required"` // Can be email or username
    Password string `json:"password" validate:"required,min=6"`
}
```

---

## ✅ Benefits

1. **Flexible Login** - Users can choose email or username
2. **User Friendly** - Easier to remember username than email
3. **Single Endpoint** - No need separate `/login-email` and `/login-username`
4. **Efficient Query** - Single database query with OR condition
5. **Backward Compatible** - Existing email login still works

---

## 🔒 Security

### Password Hashing

Passwords are hashed using bcrypt:

```go
// Register: Hash before storing
hashedPassword, _ := utils.HashPassword(password)

// Login: Compare hashes
utils.CompareHashAndPassword(hashedPassword, plainPassword)
```

### JWT Token

After successful login, JWT token is generated:

```go
tokenData := map[string]interface{}{
    "user_id": user.ID,
    "email":   user.Email,
    "name":    user.Name,
}
token, _ := h.jwt.GenerateToken(tokenData)
```

---

## 🧪 Testing

### Test Login with Email

```bash
# 1. Register user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "username": "testuser",
    "email": "test@example.com",
    "password": "test123456"
  }'

# 2. Login with email
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "test@example.com",
    "password": "test123456"
  }'
```

### Test Login with Username

```bash
# Login with username
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "testuser",
    "password": "test123456"
  }'
```

### Test Error Cases

```bash
# Wrong password
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "testuser",
    "password": "wrongpassword"
  }'

# Non-existent user
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "nonexistent",
    "password": "password123"
  }'

# Empty identity
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "",
    "password": "password123"
  }'
```

---

## 📊 Database Schema

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Index for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
```

---

## 🔮 Future Enhancements

- [ ] Password reset via email
- [ ] Email verification
- [ ] Two-factor authentication (2FA)
- [ ] Social login (Google, GitHub, etc)
- [ ] Remember me functionality
- [ ] Login history/activity log
- [ ] Account lockout after failed attempts
- [ ] OAuth2 integration

---

## 📝 Notes

1. **Username Uniqueness**: Usernames must be unique (enforced by database constraint)
2. **Email Uniqueness**: Emails must be unique (enforced by database constraint)
3. **Password Requirements**: Minimum 6 characters (can be increased in validation)
4. **Token Expiration**: JWT tokens expire based on config (default: 60 days)
5. **Case Sensitivity**: Identity search is case-sensitive by default

---

**Last Updated:** January 2025  
**Version:** 2.0.0 - Added login with username support
