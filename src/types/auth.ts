// Sama seperti book.ts, ini "best guess" struktur response.
// Cek langsung ke POST /auth/login di Swagger buat mastiin field-nya persis apa.

export interface User {
  id: string;
  name: string;
  email: string;
  role: "admin" | "user";
}

export interface LoginPayload {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface AuthState {
  token: string | null;
  user: User | null;
}
